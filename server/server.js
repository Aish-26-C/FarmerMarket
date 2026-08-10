const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("path");
require("dotenv").config({ override: true });


const app = express();


// =====================================================
// MIDDLEWARE
// =====================================================

// Enable CORS
app.use(
  cors({
    origin: "*",
    methods: [
      "GET",
      "POST",
      "PUT",
      "PATCH",
      "DELETE",
      "OPTIONS",
    ],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
    ],
  })
);

// Parse JSON requests
app.use(express.json());

// Parse URL encoded requests
app.use(
  express.urlencoded({
    extended: true,
  })
);


// =====================================================
// STATIC FILES
// =====================================================

// Make uploaded crop images publicly accessible
app.use(
  "/uploads",
  express.static(
    path.join(__dirname, "uploads")
  )
);


// =====================================================
// ROUTES
// =====================================================

const authRoutes =
  require("./routes/auth");

const cropRoutes =
  require("./routes/crops");

const orderRoutes =
  require("./routes/orders");


// Authentication
app.use(
  "/api/auth",
  authRoutes
);

// Crop marketplace
app.use(
  "/api/crops",
  cropRoutes
);

// Orders
app.use(
  "/api/orders",
  orderRoutes
);


// =====================================================
// HEALTH CHECK
// =====================================================

app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message:
      "Farmer Market API is running",
    status: "success",
    version: "1.0.0",
  });
});


// =====================================================
// API HEALTH CHECK
// =====================================================

app.get(
  "/api/health",
  (req, res) => {
    res.status(200).json({
      success: true,
      message:
        "Farmer Market backend is healthy",
      database:
        mongoose.connection.readyState === 1
          ? "connected"
          : "disconnected",
      timestamp:
        new Date().toISOString(),
    });
  }
);


// =====================================================
// 404 HANDLER
// =====================================================

app.use(
  (req, res) => {
    res.status(404).json({
      success: false,
      message:
        `Route not found: ${req.method} ${req.originalUrl}`,
    });
  }
);


// =====================================================
// GLOBAL ERROR HANDLER
// =====================================================

app.use(
  (err, req, res, next) => {
    console.error(
      "Global error:",
      err
    );

    // Multer file-size error
    if (
      err.code ===
      "LIMIT_FILE_SIZE"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Image size cannot exceed 5 MB",
      });
    }

    // Multer too many files
    if (
      err.code ===
      "LIMIT_FILE_COUNT"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Maximum 5 images are allowed",
      });
    }

    // Invalid image type
    if (
      err.message &&
      err.message.includes(
        "Only JPG"
      )
    ) {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    res.status(
      err.statusCode || 500
    ).json({
      success: false,
      message:
        err.message ||
        "Internal server error",
    });
  }
);


// =====================================================
// MONGODB CONNECTION
// =====================================================

const MONGO_URI =
  process.env.MONGO_URI;

if (!MONGO_URI) {
  console.error(
    "ERROR: MONGO_URI is missing from .env"
  );

  process.exit(1);
}

mongoose
  .connect(MONGO_URI, {
    retryWrites: false,
  })
  .then(() => {
    console.log("MongoDB connected successfully");
    startServer();
  })
  .catch((error) => {
    console.error(
      "MongoDB connection failed:",
      error.message
    );
    process.exit(1);
  });

// =====================================================
// START SERVER
// =====================================================

const PORT =
  process.env.PORT || 3000;

function startServer() {
  app.listen(
    PORT,
    "0.0.0.0",
    () => {
      console.log(
        `Server running on http://localhost:${PORT}`
      );

      console.log(
        "Farmer Market backend ready"
      );
    }
  );
}


// =====================================================
// GRACEFUL SHUTDOWN
// =====================================================

process.on(
  "SIGINT",
  async () => {
    console.log(
      "\nShutting down server..."
    );

    await mongoose.connection.close();

    process.exit(0);
  }
);

process.on(
  "SIGTERM",
  async () => {
    console.log(
      "\nShutting down server..."
    );

    await mongoose.connection.close();

    process.exit(0);
  }
);