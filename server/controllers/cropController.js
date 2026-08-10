const Crop = require("../models/Crop");

// =====================================================
// ADD CROP
// POST /api/crops
// =====================================================

exports.addCrop = async (req, res) => {
  try {
    const {
      name,
      category,
      description,
      price,
      quantity,
      unit,
      harvestDate,
      isOrganic,
      location,
    } = req.body;

    // Required fields
    if (
      !name ||
      !category ||
      price === undefined ||
      quantity === undefined
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Name, category, price and quantity are required",
      });
    }

    // Only farmers can add crops
    if (req.user.role !== "farmer") {
      return res.status(403).json({
        success: false,
        message: "Only farmers can add crops",
      });
    }

    // Validate price
    const cropPrice = Number(price);

    if (isNaN(cropPrice) || cropPrice < 0) {
      return res.status(400).json({
        success: false,
        message: "Price must be a valid positive number",
      });
    }

    // Validate quantity
    const cropQuantity = Number(quantity);

    if (isNaN(cropQuantity) || cropQuantity < 0) {
      return res.status(400).json({
        success: false,
        message:
          "Quantity must be a valid positive number",
      });
    }

    // ================================================
    // IMAGES
    // ================================================

    const images = (req.files || []).map((file) => {
      return `/uploads/${file.filename}`;
    });

    // ================================================
    // LOCATION
    // ================================================

    let parsedLocation = {};

    if (location) {
      try {
        parsedLocation =
          typeof location === "string"
            ? JSON.parse(location)
            : location;
      } catch (error) {
        return res.status(400).json({
          success: false,
          message: "Invalid location format",
        });
      }
    }

    // ================================================
    // CREATE CROP
    // ================================================

    const crop = await Crop.create({
      farmer: req.user._id,

      name: name.trim(),

      category,

      description: description
        ? description.trim()
        : "",

      price: cropPrice,

      quantity: cropQuantity,

      unit: unit || "kg",

      images,

      location: parsedLocation,

      harvestDate: harvestDate || null,

      isOrganic:
        isOrganic === true ||
        isOrganic === "true",

      isAvailable: cropQuantity > 0,
    });

    // Populate farmer information
    const populatedCrop = await Crop.findById(
      crop._id
    ).populate(
      "farmer",
      "name email phone profileImage"
    );

    return res.status(201).json({
      success: true,
      message: "Crop added successfully",
      crop: populatedCrop,
    });

  } catch (error) {
    console.error("Add crop error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to add crop",
      error: error.message,
    });
  }
};


// =====================================================
// GET ALL AVAILABLE CROPS
// GET /api/crops
// =====================================================

exports.getCrops = async (req, res) => {
  try {
    const {
      search,
      category,
      minPrice,
      maxPrice,
      city,
      organic,
      sort,
      page = 1,
      limit = 12,
    } = req.query;

    // ================================================
    // BASE FILTER
    // ================================================

    const filter = {
      isAvailable: true,
      quantity: {
        $gt: 0,
      },
    };

    // ================================================
    // SEARCH
    // ================================================

    if (search) {
      filter.$text = {
        $search: search,
      };
    }

    // ================================================
    // CATEGORY
    // ================================================

    if (category) {
      filter.category = category;
    }

    // ================================================
    // PRICE RANGE
    // ================================================

    if (minPrice || maxPrice) {
      filter.price = {};

      if (minPrice) {
        filter.price.$gte = Number(minPrice);
      }

      if (maxPrice) {
        filter.price.$lte = Number(maxPrice);
      }
    }

    // ================================================
    // CITY
    // ================================================

    if (city) {
      filter["location.city"] = {
        $regex: city,
        $options: "i",
      };
    }

    // ================================================
    // ORGANIC
    // ================================================

    if (organic === "true") {
      filter.isOrganic = true;
    }

    // ================================================
    // PAGINATION
    // ================================================

    const pageNumber = Math.max(
      Number(page),
      1
    );

    const limitNumber = Math.min(
      Math.max(Number(limit), 1),
      50
    );

    const skip =
      (pageNumber - 1) *
      limitNumber;

    // ================================================
    // SORTING
    // ================================================

    let sortOption = {
      createdAt: -1,
    };

    if (sort === "price_low") {
      sortOption = {
        price: 1,
      };
    }

    if (sort === "price_high") {
      sortOption = {
        price: -1,
      };
    }

    if (sort === "rating") {
      sortOption = {
        rating: -1,
      };
    }

    if (sort === "popular") {
      sortOption = {
        views: -1,
      };
    }

    if (sort === "newest") {
      sortOption = {
        createdAt: -1,
      };
    }

    // ================================================
    // FETCH CROPS
    // ================================================

    const crops = await Crop.find(filter)
      .populate(
        "farmer",
        "name profileImage location"
      )
      .sort(sortOption)
      .skip(skip)
      .limit(limitNumber);

    // ================================================
    // TOTAL
    // ================================================

    const total =
      await Crop.countDocuments(filter);

    return res.status(200).json({
      success: true,

      count: crops.length,

      total,

      page: pageNumber,

      pages: Math.ceil(
        total / limitNumber
      ),

      crops,
    });

  } catch (error) {
    console.error(
      "Get crops error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Failed to fetch crops",
      error: error.message,
    });
  }
};


// =====================================================
// GET SINGLE CROP
// GET /api/crops/:id
// =====================================================

exports.getCropById = async (
  req,
  res
) => {
  try {
    const crop =
      await Crop.findById(
        req.params.id
      ).populate(
        "farmer",
        "name email phone profileImage location"
      );

    if (!crop) {
      return res.status(404).json({
        success: false,
        message: "Crop not found",
      });
    }

    // Increase views
    crop.views += 1;

    await crop.save();

    return res.status(200).json({
      success: true,
      crop,
    });

  } catch (error) {
    console.error(
      "Get crop error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Failed to fetch crop",
      error: error.message,
    });
  }
};


// =====================================================
// UPDATE CROP
// PUT /api/crops/:id
// =====================================================

exports.updateCrop = async (
  req,
  res
) => {
  try {
    const crop =
      await Crop.findById(
        req.params.id
      );

    // Crop does not exist
    if (!crop) {
      return res.status(404).json({
        success: false,
        message: "Crop not found",
      });
    }

    // ================================================
    // OWNERSHIP CHECK
    // ================================================

    if (
      crop.farmer.toString() !==
      req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You can only update your own crops",
      });
    }

    // ================================================
    // NAME
    // ================================================

    if (
      req.body.name !== undefined
    ) {
      if (
        !req.body.name.trim()
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Crop name cannot be empty",
        });
      }

      crop.name =
        req.body.name.trim();
    }

    // ================================================
    // CATEGORY
    // ================================================

    if (
      req.body.category !== undefined
    ) {
      const validCategories = [
        "vegetables",
        "fruits",
        "grains",
        "pulses",
        "spices",
        "oilseeds",
        "other",
      ];

      if (
        !validCategories.includes(
          req.body.category
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid crop category",
        });
      }

      crop.category =
        req.body.category;
    }

    // ================================================
    // DESCRIPTION
    // ================================================

    if (
      req.body.description !==
      undefined
    ) {
      crop.description =
        req.body.description;
    }

    // ================================================
    // PRICE
    // ================================================

    if (
      req.body.price !== undefined
    ) {
      const price =
        Number(req.body.price);

      if (
        isNaN(price) ||
        price < 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Price must be a valid positive number",
        });
      }

      crop.price = price;
    }

    // ================================================
    // QUANTITY
    // ================================================

    if (
      req.body.quantity !==
      undefined
    ) {
      const quantity =
        Number(
          req.body.quantity
        );

      if (
        isNaN(quantity) ||
        quantity < 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Quantity must be a valid positive number",
        });
      }

      crop.quantity =
        quantity;
    }

    // ================================================
    // UNIT
    // ================================================

    if (
      req.body.unit !== undefined
    ) {
      const validUnits = [
        "kg",
        "gram",
        "quintal",
        "ton",
        "piece",
      ];

      if (
        !validUnits.includes(
          req.body.unit
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid unit",
        });
      }

      crop.unit =
        req.body.unit;
    }

    // ================================================
    // HARVEST DATE
    // ================================================

    if (
      req.body.harvestDate !==
      undefined
    ) {
      crop.harvestDate =
        req.body.harvestDate ||
        null;
    }

    // ================================================
    // ORGANIC
    // ================================================

    if (
      req.body.isOrganic !==
      undefined
    ) {
      crop.isOrganic =
        req.body.isOrganic ===
          true ||
        req.body.isOrganic ===
          "true";
    }

    // ================================================
    // LOCATION
    // ================================================

    if (
      req.body.location !==
      undefined
    ) {
      try {
        crop.location =
          typeof req.body.location ===
          "string"
            ? JSON.parse(
                req.body.location
              )
            : req.body.location;

      } catch (error) {

        return res.status(400).json({
          success: false,
          message:
            "Invalid location format",
        });
      }
    }

    // ================================================
    // ADD NEW IMAGES
    // ================================================

    if (
      req.files &&
      req.files.length > 0
    ) {
      const newImages =
        req.files.map(
          (file) =>
            `/uploads/${file.filename}`
        );

      crop.images = [
        ...crop.images,
        ...newImages,
      ];
    }

    // Maximum 5 images
    if (
      crop.images.length > 5
    ) {
      crop.images =
        crop.images.slice(0, 5);
    }

    // ================================================
    // AVAILABILITY
    // ================================================

    crop.isAvailable =
      crop.quantity > 0;

    // ================================================
    // SAVE
    // ================================================

    await crop.save();

    // Populate farmer
    const updatedCrop =
      await Crop.findById(
        crop._id
      ).populate(
        "farmer",
        "name email phone profileImage"
      );

    return res.status(200).json({
      success: true,
      message:
        "Crop updated successfully",
      crop: updatedCrop,
    });

  } catch (error) {
    console.error(
      "Update crop error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to update crop",
      error: error.message,
    });
  }
};


// =====================================================
// DELETE CROP
// DELETE /api/crops/:id
// =====================================================

exports.deleteCrop = async (
  req,
  res
) => {
  try {
    const crop =
      await Crop.findById(
        req.params.id
      );

    if (!crop) {
      return res.status(404).json({
        success: false,
        message: "Crop not found",
      });
    }

    // Only owner can delete
    if (
      crop.farmer.toString() !==
      req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You can only delete your own crops",
      });
    }

    await crop.deleteOne();

    return res.status(200).json({
      success: true,
      message:
        "Crop deleted successfully",
    });

  } catch (error) {
    console.error(
      "Delete crop error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to delete crop",
      error: error.message,
    });
  }
};


// =====================================================
// GET MY CROPS
// GET /api/crops/farmer/my-crops
// =====================================================

exports.getMyCrops = async (
  req,
  res
) => {
  try {
    const crops =
      await Crop.find({
        farmer: req.user._id,
      }).sort({
        createdAt: -1,
      });

    return res.status(200).json({
      success: true,
      count: crops.length,
      crops,
    });

  } catch (error) {
    console.error(
      "Get my crops error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Failed to fetch your crops",
      error: error.message,
    });
  }
};