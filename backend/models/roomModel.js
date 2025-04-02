const mongoose = require("mongoose");

const roomSchema = new mongoose.Schema({
  roomId: { type: String, required: true, unique: true, index: true },
  hostId: { type: String, required: true },
  players: [
    {
      sessionId: { type: String, required: true },
      username: { type: String, required: true },
      color: { type: String, required: true }
    }
  ],
  gameState: {
    turn: { type: Number, default: 0 }, // Whose turn it is (0-3 for 4 players)
    diceRoll: { type: Number, default: 0 }, // Last rolled dice number
    positions: { type: Object, default: {} }, // Player piece positions
    started: { type: Boolean, default: false } // Game started or not
  },
  createdAt: { type: Date, default: Date.now }
});

// Limit players to max 4
roomSchema.path("players").validate((players) => players.length <= 4, "Room cannot have more than 4 players.");

module.exports = mongoose.model("Room", roomSchema);
