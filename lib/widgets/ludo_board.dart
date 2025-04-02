import 'package:flutter/material.dart';

class LudoBoard extends StatelessWidget {
  final Map<String, String> playerColors;
  final Map<String, List<List<int>>> playerPositions;
  final void Function(String playerId, int pieceIndex)
  onPieceTapped; // Add this

  const LudoBoard({
    super.key,
    required this.playerColors,
    required this.playerPositions,
    required this.onPieceTapped, // Accept the callback
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 15,
          ),
          itemCount: 225,
          itemBuilder: (context, index) {
            int row = index ~/ 15;
            int col = index % 15;
            return LudoCell(
              row: row,
              col: col,
              playerColors: playerColors,
              playerPositions: playerPositions,
              onPieceTapped: onPieceTapped, // Pass the callback
            );
          },
        ),
      ),
    );
  }
}

class LudoCell extends StatelessWidget {
  final int row, col;
  final Map<String, String> playerColors;
  final Map<String, List<List<int>>> playerPositions;
  final void Function(String playerId, int pieceIndex)
  onPieceTapped; // Add this

  const LudoCell({
    super.key,
    required this.row,
    required this.col,
    required this.playerColors,
    required this.playerPositions,
    required this.onPieceTapped, // Accept the callback
  });

  @override
  Widget build(BuildContext context) {
    Color cellColor = getCellColor(row, col);
    Widget? piece = getPiece(row, col);
    Widget? safeSpot =
        isSafeSpot(row, col)
            ? const Icon(Icons.star, color: Colors.black, size: 16)
            : null;

    return GestureDetector(
      onTap: () {
        String? tappedPlayerId;
        int? tappedPieceIndex;

        // Find which player's piece was tapped
        for (var playerId in playerPositions.keys) {
          for (int i = 0; i < playerPositions[playerId]!.length; i++) {
            if (playerPositions[playerId]![i][0] == row &&
                playerPositions[playerId]![i][1] == col) {
              tappedPlayerId = playerId;
              tappedPieceIndex = i;
              break;
            }
          }
        }

        // If a piece was found, trigger the callback
        if (tappedPlayerId != null && tappedPieceIndex != null) {
          onPieceTapped(tappedPlayerId, tappedPieceIndex);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [if (safeSpot != null) safeSpot, if (piece != null) piece],
        ),
      ),
    );
  }

  bool isSafeSpot(int row, int col) {
    return (row == 1 && col == 6) ||
        (row == 6 && col == 1) ||
        (row == 6 && col == 13) ||
        (row == 13 && col == 8) ||
        (row == 8 && col == 13) ||
        (row == 13 && col == 6) ||
        (row == 8 && col == 1) ||
        (row == 1 && col == 8);
  }

  Color getCellColor(int row, int col) {
    // Home squares
    if (row < 6 && col < 6) {
      return (row == 5 || row == 0 || col == 0 || col == 5)
          ? const Color(0xFFFF645C)
          : const Color(0xFFFFC1C1);
    } // Red home
    if (row < 6 && col > 8) {
      return (row == 5 || row == 0 || col == 9 || col == 14)
          ? const Color(0xFF00B24C)
          : const Color(0xFF80EF80);
    } // Green home
    if (row > 8 && col < 6) {
      return (row == 9 || row == 14 || col == 0 || col == 5)
          ? const Color(0XFF00CDDB)
          : const Color(0XFFB3EBF2);
    } // Blue home
    if (row > 8 && col > 8) {
      return (row == 9 || row == 14 || col == 9 || col == 14)
          ? const Color(0XFFFFEF00)
          : const Color(0XFFFFEE8C);
    } // Yellow home

    // Paths
    if (col == 7 && row > 0 && row < 6) return const Color(0xFF00B24C);
    if (row == 1 && col == 8) return const Color(0xFF00B24C);
    if (col == 7 && row > 8 && row < 14) return const Color(0XFF00CDDB);
    if (row == 13 && col == 6) return const Color(0XFF00CDDB);
    if (row == 7 && col > 8 && col < 14) return const Color(0XFFFFEF00);
    if (row == 8 && col == 13) return const Color(0XFFFFEF00);
    if (row == 7 && col > 0 && col < 6) return const Color(0xFFFF645C);
    if (row == 6 && col == 1) return const Color(0xFFFF645C);

    // Center home
    if (row >= 6 && row <= 8 && col >= 6 && col <= 8) return Colors.grey;

    return Colors.white; // Default background
  }

  Widget? getPiece(int row, int col) {
    for (var playerId in playerPositions.keys) {
      for (int i = 0; i < playerPositions[playerId]!.length; i++) {
        if (playerPositions[playerId]![i][0] == row &&
            playerPositions[playerId]![i][1] == col) {
          Color pieceColor = getPlayerColor(playerId);
          return CircleAvatar(backgroundColor: pieceColor, radius: 10);
        }
      }
    }
    return null;
  }

  Color getPlayerColor(String playerId) {
    switch (playerColors[playerId]) {
      case "Red":
        return Colors.red;
      case "Green":
        return Colors.green;
      case "Blue":
        return Colors.blue;
      case "Yellow":
        return Colors.yellow.shade700;
      default:
        return Colors.black;
    }
  }
}
