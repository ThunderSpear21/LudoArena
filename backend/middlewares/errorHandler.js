const errorHandler = (err, req, res, next) => {
  console.error("❌ Error:", err.message);

  let statusCode = res.statusCode === 200 ? 500 : res.statusCode; // Ensure error status is not 200
  let message = err.message || "Server Error";

  // Handle specific MongoDB errors
  if (err.name === "ValidationError") {
    statusCode = 400;
    message = Object.values(err.errors).map((val) => val.message).join(", ");
  }

  if (err.code === 11000) {
    statusCode = 400;
    message = "Duplicate key error: " + JSON.stringify(err.keyValue);
  }

  res.status(statusCode).json({
    success: false,
    message,
  });
};

module.exports = errorHandler;
