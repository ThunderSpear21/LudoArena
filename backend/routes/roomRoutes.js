const express = require("express");
const { createRoom, joinRoom } = require("../controllers/roomController.js");
const { body, validationResult } = require("express-validator");

const router = express.Router();

// Middleware to validate request body
const validateRoomCreation = [
  body("roomId").notEmpty().withMessage("Room ID is required"),
  body("hostId").notEmpty().withMessage("Host ID is required"),
  body("username").notEmpty().withMessage("Username is required"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    next();
  }
];

const validateJoinRoom = [
  body("roomId").notEmpty().withMessage("Room ID is required"),
  body("sessionId").notEmpty().withMessage("Session ID is required"),
  body("username").notEmpty().withMessage("Username is required"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }
    next();
  }
];

// Routes
router.post("/create", validateRoomCreation, createRoom);
router.post("/join", validateJoinRoom, joinRoom);

// Handle invalid routes
router.all("*", (req, res) => {
  res.status(404).json({ success: false, message: "API route not found" });
});

module.exports = router;
