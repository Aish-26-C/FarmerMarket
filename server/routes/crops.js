const express = require("express");

const {
  addCrop,
  getCrops,
  getCropById,
  updateCrop,
  deleteCrop,
  getMyCrops,
} = require("../controllers/cropController");

const {
  protect,
  authorize,
} = require("../middleware/auth");

const upload = require("../middleware/upload");

const router = express.Router();


// ==========================================
// PUBLIC MARKETPLACE
// ==========================================

router.get("/", getCrops);


// ==========================================
// FARMER CROP CREATION
// ==========================================

// Up to 5 images
router.post(
  "/",
  protect,
  authorize("farmer"),
  upload.array("images", 5),
  addCrop
);


// ==========================================
// FARMER'S OWN CROPS
// ==========================================

router.get(
  "/farmer/my-crops",
  protect,
  authorize("farmer"),
  getMyCrops
);


// ==========================================
// SINGLE CROP
// ==========================================

router.get("/:id", getCropById);


// ==========================================
// UPDATE CROP
// ==========================================

router.put(
  "/:id",
  protect,
  authorize("farmer"),
  upload.array("images", 5),
  updateCrop
);


// ==========================================
// DELETE CROP
// ==========================================

router.delete(
  "/:id",
  protect,
  authorize("farmer"),
  deleteCrop
);


module.exports = router;