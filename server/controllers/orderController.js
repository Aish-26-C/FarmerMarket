const Order = require("../models/Order");
const Crop = require("../models/Crop");


// =====================================================
// PLACE ORDER
// POST /api/orders
// =====================================================

exports.placeOrder = async (req, res) => {
  try {
    const {
      items,
      shippingAddress,
      paymentMethod = "cod",
      notes = "",
    } = req.body;

    // -------------------------------------------------
    // CHECK USER ROLE
    // -------------------------------------------------

    if (req.user.role !== "buyer") {
      return res.status(403).json({
        success: false,
        message: "Only buyers can place orders",
      });
    }

    // -------------------------------------------------
    // VALIDATE ITEMS
    // -------------------------------------------------

    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Order must contain at least one item",
      });
    }

    // -------------------------------------------------
    // VALIDATE SHIPPING ADDRESS
    // -------------------------------------------------

    if (
      !shippingAddress ||
      !shippingAddress.address ||
      !shippingAddress.city ||
      !shippingAddress.state ||
      !shippingAddress.pincode ||
      !shippingAddress.phone
    ) {
      return res.status(400).json({
        success: false,
        message: "Complete shipping address is required",
      });
    }

    // -------------------------------------------------
    // VALIDATE PAYMENT METHOD
    // -------------------------------------------------

    if (!["cod", "online"].includes(paymentMethod)) {
      return res.status(400).json({
        success: false,
        message: "Invalid payment method",
      });
    }

    const orderItems = [];
    let totalAmount = 0;

    /*
      We keep track of stock reductions.

      If creating the order fails after reducing
      stock, we restore the stock.
    */
    const stockChanges = [];

    try {
      // ===============================================
      // PROCESS EVERY CART ITEM
      // ===============================================

      for (const item of items) {
        if (!item.cropId) {
          throw new Error("Crop ID is required");
        }

        const requestedQuantity = Number(
          item.quantity
        );

        // ------------------------------------------------
        // VALIDATE QUANTITY
        // ------------------------------------------------

        if (
          isNaN(requestedQuantity) ||
          requestedQuantity <= 0
        ) {
          throw new Error(
            "Quantity must be greater than zero"
          );
        }

        // ------------------------------------------------
        // ATOMIC STOCK CHECK + REDUCTION
        // ------------------------------------------------

        /*
          This is important.

          MongoDB will only update the crop if:

          1. The crop exists
          2. The crop is available
          3. Enough stock exists

          The quantity reduction happens in the
          same database operation.

          Example:

          Current stock = 100
          Requested     = 20

          100 >= 20 → YES
          100 - 20 = 80
        */

        const crop = await Crop.findOneAndUpdate(
          {
            _id: item.cropId,

            isAvailable: true,

            quantity: {
              $gte: requestedQuantity,
            },
          },

          {
            $inc: {
              quantity: -requestedQuantity,
            },
          },

          {
            new: true,
          }
        ).populate(
          "farmer",
          "name email phone profileImage"
        );

        // ------------------------------------------------
        // CROP NOT AVAILABLE / INSUFFICIENT STOCK
        // ------------------------------------------------

        if (!crop) {
          throw new Error(
            `Insufficient stock or crop unavailable for crop ${item.cropId}`
          );
        }

        // ------------------------------------------------
        // CALCULATE SUBTOTAL
        // ------------------------------------------------

        const subtotal =
          crop.price * requestedQuantity;

        totalAmount += subtotal;

        // ------------------------------------------------
        // REMEMBER STOCK CHANGE
        // ------------------------------------------------

        stockChanges.push({
          cropId: crop._id,
          quantity: requestedQuantity,
        });

        // ------------------------------------------------
        // MARK CROP UNAVAILABLE WHEN STOCK = 0
        // ------------------------------------------------

        if (crop.quantity === 0) {
          await Crop.findByIdAndUpdate(
            crop._id,
            {
              isAvailable: false,
            }
          );
        }

        // ------------------------------------------------
        // CREATE ORDER ITEM
        // ------------------------------------------------

        orderItems.push({
          crop: crop._id,

          farmer: crop.farmer._id,

          cropName: crop.name,

          image:
            crop.images &&
            crop.images.length > 0
              ? crop.images[0]
              : "",

          quantity: requestedQuantity,

          unit: crop.unit,

          pricePerUnit: crop.price,

          subtotal: subtotal,
        });
      }

      // ===============================================
      // CREATE ORDER
      // ===============================================

      const order = await Order.create({
        buyer: req.user._id,

        items: orderItems,

        totalAmount: totalAmount,

        shippingAddress: shippingAddress,

        paymentMethod: paymentMethod,

        paymentStatus: "pending",

        orderStatus: "placed",

        notes: notes,
      });

      // ===============================================
      // GET POPULATED ORDER
      // ===============================================

      const populatedOrder =
        await Order.findById(order._id)
          .populate(
            "buyer",
            "name email phone profileImage"
          )
          .populate(
            "items.farmer",
            "name email phone profileImage"
          );

      // ===============================================
      // SUCCESS RESPONSE
      // ===============================================

      return res.status(201).json({
        success: true,

        message:
          "Order placed successfully",

        order: populatedOrder,
      });

    } catch (orderError) {

      // ===============================================
      // ROLLBACK STOCK
      // ===============================================

      /*
        If something fails while creating the order,
        restore any stock that was already reduced.
      */

      for (const change of stockChanges) {
        try {
          await Crop.findByIdAndUpdate(
            change.cropId,

            {
              $inc: {
                quantity: change.quantity,
              },

              $set: {
                isAvailable: true,
              },
            }
          );
        } catch (rollbackError) {
          console.error(
            "Stock rollback failed:",
            rollbackError.message
          );
        }
      }

      throw orderError;
    }

  } catch (error) {

    console.error(
      "Place order error:",
      error.message
    );

    return res.status(400).json({
      success: false,

      message:
        error.message ||
        "Failed to place order",
    });
  }
};


// =====================================================
// GET BUYER ORDERS
// GET /api/orders/my-orders
// =====================================================

exports.getMyOrders = async (
  req,
  res
) => {
  try {

    // ------------------------------------------------
    // CHECK ROLE
    // ------------------------------------------------

    if (req.user.role !== "buyer") {
      return res.status(403).json({
        success: false,
        message:
          "Only buyers can access buyer orders",
      });
    }

    // ------------------------------------------------
    // GET ORDERS
    // ------------------------------------------------

    const orders =
      await Order.find({
        buyer: req.user._id,
      })
        .populate(
          "items.farmer",
          "name email phone profileImage"
        )
        .populate(
          "items.crop",
          "name category images price unit"
        )
        .sort({
          createdAt: -1,
        });

    // ------------------------------------------------
    // RESPONSE
    // ------------------------------------------------

    return res.status(200).json({
      success: true,

      count: orders.length,

      orders: orders,
    });

  } catch (error) {

    console.error(
      "Get buyer orders error:",
      error.message
    );

    return res.status(500).json({
      success: false,

      message:
        "Failed to fetch orders",
    });
  }
};


// =====================================================
// GET SINGLE ORDER
// GET /api/orders/:id
// =====================================================

exports.getOrderById = async (
  req,
  res
) => {
  try {

    // ------------------------------------------------
    // FIND ORDER
    // ------------------------------------------------

    const order =
      await Order.findById(
        req.params.id
      )
        .populate(
          "buyer",
          "name email phone profileImage"
        )
        .populate(
          "items.farmer",
          "name email phone profileImage"
        )
        .populate(
          "items.crop",
          "name category images price unit"
        );

    // ------------------------------------------------
    // ORDER NOT FOUND
    // ------------------------------------------------

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    // ------------------------------------------------
    // CHECK BUYER ACCESS
    // ------------------------------------------------

    const isBuyer =
      order.buyer._id.toString() ===
      req.user._id.toString();

    // ------------------------------------------------
    // CHECK FARMER ACCESS
    // ------------------------------------------------

    const isFarmer =
      order.items.some(
        (item) =>
          item.farmer &&
          item.farmer._id.toString() ===
            req.user._id.toString()
      );

    // ------------------------------------------------
    // ACCESS DENIED
    // ------------------------------------------------

    if (!isBuyer && !isFarmer) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to view this order",
      });
    }

    // ------------------------------------------------
    // RESPONSE
    // ------------------------------------------------

    return res.status(200).json({
      success: true,

      order: order,
    });

  } catch (error) {

    console.error(
      "Get order error:",
      error.message
    );

    return res.status(500).json({
      success: false,

      message:
        "Failed to fetch order",
    });
  }
};


// =====================================================
// GET FARMER ORDERS
// GET /api/orders/farmer
// =====================================================

exports.getFarmerOrders = async (
  req,
  res
) => {
  try {

    // ------------------------------------------------
    // CHECK ROLE
    // ------------------------------------------------

    if (req.user.role !== "farmer") {
      return res.status(403).json({
        success: false,

        message:
          "Only farmers can access farmer orders",
      });
    }

    // ------------------------------------------------
    // FIND ORDERS
    // ------------------------------------------------

    const orders =
      await Order.find({
        "items.farmer":
          req.user._id,
      })
        .populate(
          "buyer",
          "name email phone profileImage"
        )
        .populate(
          "items.crop",
          "name category images price unit"
        )
        .sort({
          createdAt: -1,
        });

    // ------------------------------------------------
    // RESPONSE
    // ------------------------------------------------

    return res.status(200).json({
      success: true,

      count: orders.length,

      orders: orders,
    });

  } catch (error) {

    console.error(
      "Get farmer orders error:",
      error.message
    );

    return res.status(500).json({
      success: false,

      message:
        "Failed to fetch farmer orders",
    });
  }
};


// =====================================================
// UPDATE ORDER STATUS
// PUT /api/orders/:id/status
// =====================================================

exports.updateOrderStatus = async (
  req,
  res
) => {
  try {

    const {
      status,
    } = req.body;

    // ------------------------------------------------
    // VALID STATUSES
    // ------------------------------------------------

    const validStatuses = [
      "placed",
      "confirmed",
      "processing",
      "shipped",
      "out_for_delivery",
      "delivered",
      "cancelled",
      "rejected",
    ];

    if (
      !validStatuses.includes(status)
    ) {
      return res.status(400).json({
        success: false,

        message:
          "Invalid order status",
      });
    }

    // ------------------------------------------------
    // FIND ORDER
    // ------------------------------------------------

    const order =
      await Order.findById(
        req.params.id
      );

    if (!order) {
      return res.status(404).json({
        success: false,

        message:
          "Order not found",
      });
    }

    // ------------------------------------------------
    // CHECK BUYER
    // ------------------------------------------------

    const isBuyer =
      order.buyer.toString() ===
      req.user._id.toString();

    // ------------------------------------------------
    // CHECK FARMER
    // ------------------------------------------------

    const farmerOwnsItem =
      order.items.some(
        (item) =>
          item.farmer.toString() ===
          req.user._id.toString()
      );

    // =================================================
    // BUYER RULES
    // =================================================

    if (req.user.role === "buyer") {

      if (!isBuyer) {
        return res.status(403).json({
          success: false,

          message:
            "You can only manage your own orders",
        });
      }

      // Buyers can only cancel
      if (status !== "cancelled") {
        return res.status(403).json({
          success: false,

          message:
            "Buyers can only cancel orders",
        });
      }

      // Cannot cancel shipped/delivered orders
      if (
        [
          "shipped",
          "out_for_delivery",
          "delivered",
        ].includes(
          order.orderStatus
        )
      ) {
        return res.status(400).json({
          success: false,

          message:
            "This order can no longer be cancelled",
        });
      }
    }

    // =================================================
    // FARMER RULES
    // =================================================

    if (req.user.role === "farmer") {

      if (!farmerOwnsItem) {
        return res.status(403).json({
          success: false,

          message:
            "You can only manage orders containing your crops",
        });
      }

      // Farmers cannot directly cancel
      // a delivered order
      if (
        status === "cancelled" &&
        order.orderStatus ===
          "delivered"
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Delivered orders cannot be cancelled",
        });
      }
    }

    // =================================================
    // RESTORE STOCK IF CANCELLED
    // =================================================

    if (
      status === "cancelled" &&
      order.orderStatus !== "cancelled"
    ) {

      for (
        const item
        of order.items
      ) {

        const crop =
          await Crop.findById(
            item.crop
          );

        if (crop) {

          const newQuantity =
            crop.quantity +
            item.quantity;

          await Crop.findByIdAndUpdate(
            item.crop,

            {
              $inc: {
                quantity:
                  item.quantity,
              },

              $set: {
                isAvailable:
                  newQuantity > 0,
              },
            }
          );
        }
      }
    }

    // =================================================
    // UPDATE STATUS
    // =================================================

    order.orderStatus =
      status;

    await order.save();

    // ------------------------------------------------
    // GET UPDATED ORDER
    // ------------------------------------------------

    const updatedOrder =
      await Order.findById(
        order._id
      )
        .populate(
          "buyer",
          "name email phone profileImage"
        )
        .populate(
          "items.farmer",
          "name email phone profileImage"
        )
        .populate(
          "items.crop",
          "name category images price unit"
        );

    // ------------------------------------------------
    // RESPONSE
    // ------------------------------------------------

    return res.status(200).json({
      success: true,

      message:
        "Order status updated successfully",

      order:
        updatedOrder,
    });

  } catch (error) {

    console.error(
      "Update order status error:",
      error.message
    );

    return res.status(500).json({
      success: false,

      message:
        "Failed to update order status",

      error:
        error.message,
    });
  }
};


// =====================================================
// CANCEL ORDER
// PUT /api/orders/:id/cancel
// =====================================================

exports.cancelOrder = async (
  req,
  res
) => {
  try {

    // ------------------------------------------------
    // FIND ORDER
    // ------------------------------------------------

    const order =
      await Order.findById(
        req.params.id
      );

    if (!order) {
      return res.status(404).json({
        success: false,

        message:
          "Order not found",
      });
    }

    // ------------------------------------------------
    // CHECK BUYER
    // ------------------------------------------------

    if (
      order.buyer.toString() !==
      req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,

        message:
          "You can only cancel your own orders",
      });
    }

    // ------------------------------------------------
    // CHECK STATUS
    // ------------------------------------------------

    if (
      [
        "shipped",
        "out_for_delivery",
        "delivered",
        "cancelled",
        "rejected",
      ].includes(
        order.orderStatus
      )
    ) {
      return res.status(400).json({
        success: false,

        message:
          "This order cannot be cancelled",
      });
    }

    // ------------------------------------------------
    // RESTORE STOCK
    // ------------------------------------------------

    for (
      const item
      of order.items
    ) {

      const crop =
        await Crop.findById(
          item.crop
        );

      if (crop) {

        const newQuantity =
          crop.quantity +
          item.quantity;

        await Crop.findByIdAndUpdate(
          item.crop,

          {
            $inc: {
              quantity:
                item.quantity,
            },

            $set: {
              isAvailable:
                newQuantity > 0,
            },
          }
        );
      }
    }

    // ------------------------------------------------
    // UPDATE ORDER
    // ------------------------------------------------

    order.orderStatus =
      "cancelled";

    await order.save();

    // ------------------------------------------------
    // RESPONSE
    // ------------------------------------------------

    return res.status(200).json({
      success: true,

      message:
        "Order cancelled and stock restored",

      order:
        order,
    });

  } catch (error) {

    console.error(
      "Cancel order error:",
      error.message
    );

    return res.status(500).json({
      success: false,

      message:
        "Failed to cancel order",
    });
  }
};