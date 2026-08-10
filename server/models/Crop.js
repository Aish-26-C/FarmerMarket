const mongoose = require("mongoose");

const cropSchema = new mongoose.Schema(
  {
    farmer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    name: {
      type: String,
      required: true,
      trim: true,
    },

    category: {
      type: String,
      required: true,
      enum: [
        "vegetables",
        "fruits",
        "grains",
        "pulses",
        "spices",
        "oilseeds",
        "other",
      ],
    },

    description: {
      type: String,
      default: "",
      trim: true,
    },

    price: {
      type: Number,
      required: true,
      min: 0,
    },

    quantity: {
      type: Number,
      required: true,
      min: 0,
    },

    unit: {
      type: String,
      enum: ["kg", "gram", "quintal", "ton", "piece"],
      default: "kg",
    },

    images: [
      {
        type: String,
      },
    ],

    location: {
      address: {
        type: String,
        default: "",
      },

      city: {
        type: String,
        default: "",
      },

      state: {
        type: String,
        default: "",
      },

      latitude: {
        type: Number,
        default: null,
      },

      longitude: {
        type: Number,
        default: null,
      },
    },

    harvestDate: {
      type: Date,
      default: null,
    },

    isOrganic: {
      type: Boolean,
      default: false,
    },

    isAvailable: {
      type: Boolean,
      default: true,
    },

    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },

    totalReviews: {
      type: Number,
      default: 0,
      min: 0,
    },

    views: {
      type: Number,
      default: 0,
      min: 0,
    },
  },
  {
    timestamps: true,
  }
);


// Useful indexes for marketplace search
cropSchema.index({
  name: "text",
  description: "text",
});

cropSchema.index({
  category: 1,
});

cropSchema.index({
  price: 1,
});

cropSchema.index({
  "location.city": 1,
});

cropSchema.index({
  farmer: 1,
});

cropSchema.index({
  isAvailable: 1,
});


module.exports = mongoose.model("Crop", cropSchema);