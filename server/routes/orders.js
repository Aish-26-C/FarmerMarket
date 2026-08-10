const express = require("express");

const {
  placeOrder,
  getMyOrders,
  getOrderById,
  getFarmerOrders,
  updateOrderStatus,
  cancelOrder,
} = require("../controllers/orderController");

const {
  protect,
  authorize,
} = require("../middleware/auth");

const router = express.Router();


// =====================================================
// BUYER ROUTES
// =====================================================

// Place a new order
router.post(
  "/",
  protect,
  authorize("buyer"),
  placeOrder
);


// Get logged-in buyer's orders
router.get(
  "/my-orders",
  protect,
  authorize("buyer"),
  getMyOrders
);


// Cancel an order
router.put(
  "/:id/cancel",
  protect,
  authorize("buyer"),
  cancelOrder
);


// =====================================================
// FARMER ROUTES
// =====================================================

// Get orders containing farmer's crops
router.get(
  "/farmer",
  protect,
  authorize("farmer"),
  getFarmerOrders
);


// =====================================================
// COMMON PROTECTED ROUTES
// =====================================================

// Get one order
router.get(
  "/:id",
  protect,
  getOrderById
);


// Update order status
router.put(
  "/:id/status",
  protect,
  updateOrderStatus
);


module.exports = router;