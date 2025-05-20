const Room = require("../models/roomModel");

const defaultPositions = {
  Red: [
    [2, 2],
    [2, 3],
    [3, 2],
    [3, 3],
  ],
  Green: [
    [2, 11],
    [2, 12],
    [3, 11],
    [3, 12],
  ],
  Blue: [
    [11, 2],
    [11, 3],
    [12, 2],
    [12, 3],
  ],
  Yellow: [
    [11, 11],
    [11, 12],
    [12, 11],
    [12, 12],
  ],
};

const colors = ["Red", "Green", "Blue", "Yellow"];

exports.createRoom = async (req, res) => {
  const { roomId, hostId, username } = req.body;

  if (!roomId || !hostId || !username) {
    return res
      .status(400)
      .json({ success: false, message: "Missing required fields" });
  }

  try {
    const existingRoom = await Room.findOne({ roomId });

    if (existingRoom) {
      return res
        .status(400)
        .json({ success: false, message: "Room ID already exists" });
    }

    // Assign the first available color to the host
    const hostColor = colors[0];
    const hostPosition = defaultPositions[hostColor];

    const room = await Room.create({
      roomId,
      hostId,
      players: [{ sessionId: hostId, username, color: hostColor.toString() }],
      gameState: {
        turn: 0,
        diceRoll: 1, // ✅ Set initial dice roll to 1
        positions: { [hostId]: hostPosition },
        started: false,
      },
    });
    console.log(`✅ Room Created: ${roomId}`);
    console.log("🟢 Host Added:", room.players[0]);
    return res.status(201).json({ success: true, roomId, color: hostColor });
  } catch (error) {
    console.error("Error creating room:", error.message);
    return res
      .status(500)
      .json({
        success: false,
        message: error.message || "Error creating room",
      });
  }
};

exports.joinRoom = async (req, res) => {
  const { roomId, sessionId, username } = req.body;

  try {
    const room = await Room.findOne({ roomId });

    if (!room) {
      return res
        .status(404)
        .json({ success: false, message: "Room not found" });
    }

    if (room.players.length >= 4) {
      return res.status(400).json({ success: false, message: "Room is full" });
    }

    // Check if player is already in the room
    if (room.players.some((player) => player.sessionId === sessionId)) {
      return res
        .status(400)
        .json({ success: false, message: "Player already in room" });
    }

    // Find available color
    const assignedColors = room.players.map((player) => player.color);
    const availableColor = colors.find(
      (color) => !assignedColors.includes(color)
    );

    if (!availableColor) {
      return res
        .status(400)
        .json({ success: false, message: "No available colors" });
    }

    // Add player with assigned color
    room.players.push({
      sessionId,
      username,
      color: availableColor.toString(),
    });

    // Initialize positions for this player in gameState.positions
    room.gameState.positions[sessionId] = defaultPositions[availableColor];
    room.markModified("gameState.positions");
    await room.save();

    return res.json({
      success: true,
      message: "Joined room successfully",
      color: availableColor,
    });
  } catch (error) {
    console.error("Error joining room:", error.message);
    return res
      .status(500)
      .json({ success: false, message: error.message || "Error joining room" });
  }
};
