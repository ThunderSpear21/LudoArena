const express = require("express");
const http = require("http");
const WebSocket = require("ws"); // ✅ Use WebSocket instead of socket.io
const mongoose = require("mongoose");
const cors = require("cors");
const Room = require("./models/roomModel");
const roomRoutes = require("./routes/roomRoutes");
const errorHandler = require("./middlewares/errorHandler");

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server }); // ✅ WebSocket Server

// Middleware
app.use(express.json());
app.use(cors());

// Routes
app.use("/api/room", require("./routes/roomRoutes"));

// WebSocket Handling

wss.on("connection", (ws) => {
  console.log("🟢 New WebSocket Connection");

  ws.on("message", async (message) => {
    try {
      console.log("📩 Received WebSocket message:", message);
      const data = JSON.parse(message.toString());

      if (data.type === "get_players") {
        const room = await Room.findOne({ roomId: data.roomId });

        if (room) {
          // Convert MongoDB objects into plain JSON
          const players = room.players.map((player) => ({
            sessionId: player.sessionId,
            username: player.username,
            color: player.color, // Ensure color is included
          }));

          console.log("📤 Sending player list:", players);

          ws.send(JSON.stringify({ type: "player_list", players }));
        }
      } else if (data.type === "get_game_state") {
        const room = await Room.findOne({ roomId: data.roomId });

        if (room) {
          console.log(`🎲 Fetching game state for Room: ${data.roomId}`);

          const playerColors = room.players.reduce((acc, player) => {
            console.log(
              `🟢 Player: ${player.username}, Color: ${player.color}`
            );
            acc[player.sessionId] = player.color;
            return acc;
          }, {});

          ws.send(
            JSON.stringify({
              type: "game_state",
              playerColors: room.players.reduce((acc, player) => {
                acc[player.sessionId] = {
                  username: player.username,
                  color: player.color,
                }; // ✅ Include username
                return acc;
              }, {}),
              playerPieces: room.gameState.positions,
              turnOrder: room.players.map((p) => p.sessionId),
              currentTurn: room.players[0]?.sessionId || null,
              diceRoll: room.gameState.diceRoll, // ✅ Include dice value
            })
          );
        } else {
          ws.send(JSON.stringify({ type: "error", message: "Room not found" }));
        }
      } else if (data.type === "roll_dice") {
        console.log("🎲 In roll dice in index.js");
    
        const room = await Room.findOne({ roomId: data.roomId });
    
        if (!room) {
            return ws.send(
                JSON.stringify({ type: "error", message: "Room not found" })
            );
        }
    
        console.log("Before Roll: Turn =", room.gameState.turn);
    
        if (room.players[room.gameState.turn].sessionId === data.playerId) {
            const diceValue = Math.floor(Math.random() * 6) + 1;
            console.log("🎲 Dice Value Rolled: " + diceValue);
    
            // Store dice roll in game state
            room.gameState.diceRoll = diceValue;
            room.markModified("gameState.diceRoll");
            await room.save();
    
            // Broadcast dice roll to all clients
            wss.clients.forEach((client) => {
                if (client.readyState === WebSocket.OPEN) {
                    client.send(
                        JSON.stringify({
                            type: "dice_rolled",
                            playerId: data.playerId,
                            diceValue: diceValue,
                            currentTurn: room.players[room.gameState.turn].sessionId
                        })
                    );
                }
            });
    
            console.log(`🎲 Player ${data.playerId} rolled a ${diceValue}`);
        } else {
            console.log("❌ Not this player's turn.");
        }
    }
    
    // New event to handle piece movement
    else if (data.type === "move_piece") {
        console.log("🚀 In move piece in index.js");
    
        const room = await Room.findOne({ roomId: data.roomId });
    
        if (!room) {
            return ws.send(
                JSON.stringify({ type: "error", message: "Room not found" })
            );
        }
    
        if (room.players[room.gameState.turn].sessionId !== data.playerId) {
            return console.log("❌ Not this player's turn.");
        }
    
        const player = room.players.find((p) => p.sessionId === data.playerId);
        if (!player) return;
    
        const playerColor = player.color; // "Red", "Green", etc.
    
        const paths = {
          red: [
            [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [5, 6], [4, 6], [3, 6], [2, 6], [1, 6], [0, 6], [0, 7], [0, 8],
            [1, 8], [2, 8], [3, 8], [4, 8], [5, 8], [6, 9], [6, 10], [6, 11], [6, 12], [6, 13], [6, 14], [7, 14], [8, 14], 
            [8, 13], [8, 12], [8, 11], [8, 10], [8, 9], [9, 8], [10, 8], [11, 8], [12, 8], [13, 8], [14, 8], [14, 7], [14, 6], 
            [13, 6], [12, 6], [11, 6], [10, 6], [9, 6], [8, 5], [8, 4], [8, 3], [8, 2], [8, 1], [8, 0], [7, 0], [7, 1], 
            [7, 2], [7, 3], [7, 4], [7, 5], [7, 6]
          ],
          green: [
            [1, 8], [2, 8], [3, 8], [4, 8], [5, 8], [6, 9], [6, 10], [6, 11], [6, 12], [6, 13], [6, 14], [7, 14], [8, 14], 
            [8, 13], [8, 12], [8, 11], [8, 10], [8, 9], [9, 8], [10, 8], [11, 8], [12, 8], [13, 8], [14, 8], [14, 7], [14, 6], 
            [13, 6], [12, 6], [11, 6], [10, 6], [9, 6], [8, 5], [8, 4], [8, 3], [8, 2], [8, 1], [8, 0], [7, 0], [6, 0], 
            [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [5, 6], [4, 6], [3, 6], [2, 6], [1, 6], [0, 6], [0, 7], [1, 7], 
            [2, 7], [3, 7], [4, 7], [5, 7], [6, 7]
          ],
          blue: [
            [13, 6], [12, 6], [11, 6], [10, 6], [9, 6], [8, 5], [8, 4], [8, 3], [8, 2], [8, 1], [8, 0], [7, 0], [6, 0], 
            [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [5, 6], [4, 6], [3, 6], [2, 6], [1, 6], [0, 6], [0, 7], [0, 8], 
            [1, 8], [2, 8], [3, 8], [4, 8], [5, 8], [6, 9], [6, 10], [6, 11], [6, 12], [6, 13], [6, 14], [7, 14], [8, 14], 
            [8, 13], [8, 12], [8, 11], [8, 10], [8, 9], [9, 8], [10, 8], [11, 8], [12, 8], [13, 8], [14, 8], [14, 7], 
            [13, 7], [12, 7], [11, 7], [10, 7], [9, 7], [8, 7]
          ],
          yellow: [
            [8, 13], [8, 12], [8, 11], [8, 10], [8, 9], [9, 8], [10, 8], [11, 8], [12, 8], [13, 8], [14, 8], [14, 7], [14, 6], 
            [13, 6], [12, 6], [11, 6], [10, 6], [9, 6], [8, 5], [8, 4], [8, 3], [8, 2], [8, 1], [8, 0], [7, 0], [6, 0], 
            [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [5, 6], [4, 6], [3, 6], [2, 6], [1, 6], [0, 6], [0, 7], [0, 8], 
            [1, 8], [2, 8], [3, 8], [4, 8], [5, 8], [6, 9], [6, 10], [6, 11], [6, 12], [6, 13], [6, 14], [7, 14], 
            [7, 13], [7, 12], [7, 11], [7, 10], [7, 9], [7, 8]
          ]
        };
        
    
        const defaultPositions = {
            Red: [[2, 2], [2, 3], [3, 2], [3, 3]],
            Green: [[2, 11], [2, 12], [3, 11], [3, 12]],
            Blue: [[11, 2], [11, 3], [12, 2], [12, 3]],
            Yellow: [[11, 11], [11, 12], [12, 11], [12, 12]]
        };
    
        const path = paths[playerColor.toLowerCase()];
        if (!path) {
            console.error(`❌ Path not found for color ${playerColor}`);
            return;
        }
    
        if (!room.gameState.positions[data.playerId]) {
            room.gameState.positions[data.playerId] = [...defaultPositions[playerColor]];
        }
    
        console.log("📍 Current positions:", JSON.stringify(room.gameState.positions, null, 2));
    
        // Get the selected piece index
        const pieceIndex = data.pieceIndex;
        if (pieceIndex < 0 || pieceIndex >= 4) {
            return console.error("❌ Invalid piece index.");
        }
    
        let piecePosition = room.gameState.positions[data.playerId][pieceIndex];
        console.log("Selected piece position:", piecePosition);
    
        // Check if the piece is in the start area
        const isInStartArea = defaultPositions[playerColor].some(
            (startPos) => startPos[0] === piecePosition[0] && startPos[1] === piecePosition[1]
        );
    
        let newPosition;
        if (isInStartArea) {
            newPosition = path[0]; // Move out of the start area
        } else {
            let currentIndex = path.findIndex(
                (pos) => pos[0] === piecePosition[0] && pos[1] === piecePosition[1]
            );
    
            if (currentIndex === -1) {
                return console.error("❌ Current position not found in path.");
            }
    
            let newIndex = currentIndex + room.gameState.diceRoll;
            if (newIndex >= path.length) newIndex = currentIndex; // Stay within bounds
    
            newPosition = path[newIndex];
        }
    
        console.log(`🟢 Piece ${pieceIndex} moving to ${newPosition}`);
    
        // Update piece position in DB
        room.gameState.positions[data.playerId][pieceIndex] = newPosition;
    
        // Move to next player
        room.gameState.turn = (room.gameState.turn + 1) % room.players.length;
        room.gameState.diceRoll = null; // Reset dice roll after movement
        room.markModified("gameState.positions");
        await room.save();
    
        console.log("🔄 Updated positions:", JSON.stringify(room.gameState.positions, null, 2));
    
        // Broadcast piece movement to all clients
        wss.clients.forEach((client) => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(
                    JSON.stringify({
                        type: "piece_moved",
                        currentTurn: room.players[room.gameState.turn].sessionId,
                        playerId: data.playerId,
                        pieceIndex: pieceIndex,
                        oldPosition: piecePosition,
                        newPosition: newPosition
                    })
                );
            }
        });
    
        console.log(`🚀 Player ${data.playerId} moved piece ${pieceIndex} to ${newPosition}`);
    }
     else if (data.type === "start_game") {
        const room = await Room.findOne({ roomId: data.roomId });

        if (room) {
          const players = room.players.map((player) => ({
            sessionId: player.sessionId,
            username: player.username,
            color: player.color,
          }));

          console.log("🎮 Game Started! Sending update to all clients.");

          // ✅ Broadcast to all connected clients
          wss.clients.forEach((client) => {
            if (client.readyState === WebSocket.OPEN) {
              client.send(JSON.stringify({ type: "game_started", players }));
            }
          });
        }
      }
    } catch (error) {
      console.error("❌ WebSocket Error:", error.message);
      ws.send(
        JSON.stringify({ type: "error", message: "Invalid message format" })
      );
    }
  });

  ws.on("close", () => {
    console.log("🔴 WebSocket Disconnected");
  });
});

// Error Handling Middleware
app.use(errorHandler);

// Connect to MongoDB and Start Server
mongoose
  .connect(
    "mongodb+srv://yashkshitiz21:YashMongoDB@fluttergame.eigyd.mongodb.net/"
  )
  .then(() => {
    console.log("✅ Connected to MongoDB");
    server.listen(5000, () => console.log("✅ Server running on port 5000"));
  })
  .catch((err) => {
    console.error("❌ MongoDB Connection Error:", err);
    process.exit(1);
  });
