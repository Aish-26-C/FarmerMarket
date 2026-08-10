const mongoose = require("mongoose");

const orderItemSchema = new mongoose.Schema(
  {
    crop: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Crop",
      required: true,
    },

    farmer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    cropName: {
      type: String,
      required: true,
    },

    image: {
      type: String,
      default: "",
    },

    quantity: {
      type: Number,
      required: true,
      min: 0.01,
    },

    unit: {
      type: String,
      required: true,
    },

    pricePerUnit: {
      type: Number,
      required: true,
      min: 0,
    },

    subtotal: {
      type: Number,
      required: true,
      min: 0,
    },
  },
  {
    _id: false,
  }
);


const orderSchema = new mongoose.Schema(
  {
    buyer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    items: {
      type: [orderItemSchema],
      required: true,
      validate: {
        validator: function (items) {
          return items.length > 0;
        },
        message: "Order must contain at least one item",
      },
    },

    totalAmount: {
      type: Number,
      required: true,
      min: 0,
    },

    shippingAddress: {
      address: {
        type: String,
        required: true,
      },

      city: {
        type: String,
        required: true,
      },

      state: {
        type: String,
        required: true,
      },

      pincode: {
        type: String,
        required: true,
      },

      phone: {
        type: String,
        required: true,
      },
    },

    paymentMethod: {
      type: String,
      enum: [
        "cod",
        "online",
      ],
      default: "cod",
    },

    paymentStatus: {
      type: String,
      enum: [
        "pending",
        "paid",
        "failed",
        "refunded",
      ],
      default: "pending",
    },

    orderStatus: {
      type: String,
      enum: [
        "placed",
        "confirmed",
        "processing",
        "shipped",
        "out_for_delivery",
        "delivered",
        "cancelled",
        "rejected",
      ],
      default: "placed",
    },

    notes: {
      type: String,
      default: "",
    },

    trackingNumber: {
      type: String,
      default: "",
    },
  },
  {
    timestamps: true,
  }
);


// Useful indexes
orderSchema.index({
  buyer: 1,
});

orderSchema.index({
  "items.farmer": 1,
});

orderSchema.index({
  orderStatus: 1,
});

orderSchema.index({
  createdAt: -1,
});


module.exports = mongoose.model(
  "Order",
  orderSchema
);