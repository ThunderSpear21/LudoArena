const Room = require("../models/roomModel");

const socketManager = (io) => {
  io.on("connection", (socket) => {
    console.log("🟢 New WebSocket connection:", socket.id);

    // Handle joining a room
    socket.on("joinRoom", async ({ roomId, sessionId, username }) => {
      try {
        let room = await Room.findOne({ roomId });

        if (!room) {
          socket.emit("error", { message: "Room not found" });
          return;
        }

        if (room.players.length >= 4) {
          socket.emit("error", { message: "Room is full" });
          return;
        }

        // Add player to room if not already present
        if (!room.players.some((player) => player.sessionId === sessionId)) {
          room.players.push({ sessionId, username });
          await room.save(); // ✅ Save updated room to DB
        }

        socket.join(roomId);
        io.to(roomId).emit("playerJoined", { sessionId, username });

        console.log(`📌 Player ${username} joined room ${roomId}`);
      } catch (error) {
        console.error("❌ Database error:", error.message);
        socket.emit("error", { message: "Internal server error" });
      }
    });

    // Handle player disconnection
    socket.on("disconnect", async () => {
      console.log("🔴 WebSocket disconnected:", socket.id);

      try {
        let room = await Room.findOne({ "players.sessionId": socket.id });

        if (room) {
          room.players = room.players.filter(player => player.sessionId !== socket.id);
          await room.save(); // ✅ Remove player from DB
          
          io.to(room.roomId).emit("playerLeft", { sessionId: socket.id });

          console.log(`📌 Player ${socket.id} left room ${room.roomId}`);
        }
      } catch (error) {
        console.error("❌ Error handling player disconnect:", error.message);
      }
    });
  });
};

module.exports = socketManager;
