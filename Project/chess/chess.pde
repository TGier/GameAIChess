/*
- Minimax vs MCTS Chess
- Created by Tyler Gier and Christopher DiNome

For human players:
- Clicking a piece will select it for movement
- LEGAL moves for the selected piece are highlighted in blue
  - If you are in check, it will only allow you to make moves that move you out of check
- Text at the bottom alerts the current player to if they are in check
- Clicking a highlighted square will move the selected piece to that square
- Clicking another piece of yours will select the newly clicked piece for movement
- For promoting pawns, select the type of piece you'd like to promote to in the bottom right BEFORE moving the pawn into the promotion row

Assumptions/Setup:
- White goes first
- For minimax, white is max
- White is at bottom, moving upwards
- Images are used from wikimedia commons and available under creative commons
*/

// Setting to TRUE allows the game to be "stepped" by pressing a key instead of time so AI moves can be followed easier
boolean DEBUG = false;

enum PlayerType {
  HUMAN, RANDOM, MINIMAX, MCTS
}

// TO CHANGE PLAYER TYPES, MODIFY THESE VALUES USING THE ENUMS
PlayerType whitePlayer = PlayerType.HUMAN;
PlayerType blackPlayer = PlayerType.HUMAN;

// Game logic valuse
ChessBoard gameBoard;
boolean whiteMove = true;
boolean gameOver = false;

// Rendering values
static final int BOARD_WIDTH = 8;
static final int GRID_SIZE = 480 / BOARD_WIDTH;
final color LIGHT_SQUARE = color(247, 243, 195);
final color DARK_SQUARE = color(96, 72, 5);
ArrayList<Pair> squareHighlights;
String gameStatus = whiteMove ? "White turn" : "Black turn";

// Human player input values
ChessPiece playerSelectedPiece;
ArrayList<ChessPiece[][]> playerLegalMoves;
ChessPiece promotionPiece;
ArrayList<ChessPiece> promotionPieces;

void setup() {
  size(480, 540);
  frameRate(30);
  gameBoard = new ChessBoard();
  squareHighlights = new ArrayList<Pair>();
  
  promotionPieces = new ArrayList<ChessPiece>();
  promotionPieces.add(new Rook(100, true));
  promotionPieces.add(new Knight(101, true));
  promotionPieces.add(new Bishop(102, true));
  promotionPieces.add(new Queen(103, true));
  promotionPiece = promotionPieces.get(3);
}

void draw() {
  if (gameOver) {
    return;
  }
  background(color(150, 150, 150));
  gameBoard.draw();
  drawPromotionSelect();
  
  if (!DEBUG) {
    playMove();
    drawGameStatusText(gameStatus);
  } //<>//
}

void keyPressed() {
 if (DEBUG) {
   playMove();
   drawGameStatusText(gameStatus);
 }
}


void drawGameStatusText(String text) { 
  fill(color(0,0,0));
  textSize(14);
  text(text, 20, 500);
}

void drawPromotionSelect() {
  fill(color(0,0,0));
  textSize(12);
  text("Player Promotion:", 140, 530);
  for (int i = 0; i < promotionPieces.size(); i++) {
    ChessPiece piece = promotionPieces.get(i);
    int xPos = 240 + (GRID_SIZE * i);
    if (piece == promotionPiece) {
      noStroke();
      fill(color(20, 229, 149));
      rect(xPos, 480, GRID_SIZE, GRID_SIZE);
    }
    piece.draw(8, 4 + i);
  }
}

void playMove() {
  ArrayList<ChessPiece[][]> possibleBoards = gameBoard.getPossibleMoves(whiteMove);
  gameStatus = whiteMove ? "White move" : "Black move";
  // Check for checkmate or easy stalemate
  boolean inCheck = gameBoard.isCurrentBoardInCheck(whiteMove);
  if (inCheck && possibleBoards.isEmpty()) {
    gameStatus = "CHECKMATE! " + (whiteMove ? "BLACK" : "WHITE") + " WINS!";
    gameOver = true;
    return;
  } else if (possibleBoards.isEmpty()) {
    gameStatus = "Stalemate!"; // No legal moves, but not in check
    gameOver = true;
    return;
  } else if (inCheck) {
    gameStatus = (whiteMove ? "White move" : "Black move") + ", IN CHECK!";
  }
  
  drawGameStatusText(gameStatus);
 
  PlayerType currentActor = whiteMove ? whitePlayer : blackPlayer;
  switch (currentActor) {
    case HUMAN:
      checkHumanInput();
      break;
    case RANDOM:
      gameBoard.makeRandomMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
    case MINIMAX:
      gameBoard.makeMinimaxMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
    case MCTS:
      gameBoard.makeMCTSMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
  }
}

void checkHumanInput() {
  if (!mousePressed || (mousePressed && mouseY > 480 && mouseX < 240)) {
    return;
  } else if (mouseY > 480 && mouseX > 240) {
    promotionPiece = promotionPieces.get((mouseX - 240) / GRID_SIZE);
    return;
  }
  
  int row = mouseY / GRID_SIZE;
  int col = mouseX / GRID_SIZE;
  ChessPiece clickedPiece = gameBoard.getPiece(row, col, whiteMove);
  if (clickedPiece != null) {
    playerSelectedPiece = clickedPiece;
    playerLegalMoves = gameBoard.getLegalMovesForPiece(playerSelectedPiece);
    squareHighlights.clear();
    for (ChessPiece[][] b : playerLegalMoves) {
      squareHighlights.add(getLocationForPieceInBoard(b, playerSelectedPiece.id));
    }
  }
  
  for (ChessPiece[][] cb : playerLegalMoves) {
    if (cb[row][col] != null && cb[row][col].id == playerSelectedPiece.id) {
      // If player is moving a pawn, it must either stay a pawn or promote. In the case of promotion, the possible moves have the pawn in the same place or have the right promotion type
      if (playerSelectedPiece instanceof Pawn && !(cb[row][col] instanceof Pawn || cb[row][col].getClass().equals(promotionPiece.getClass()))) {
        continue;
      } 
      gameBoard.setBoard(cb);
      whiteMove = !whiteMove; 
      playerSelectedPiece = null;
      playerLegalMoves.clear();
      squareHighlights.clear();
      return;
    }
  } 
}

// MARK: utility functions/class not in ChessUtils

// Due to ChessUtils being static, this couldn't be moved into it because Java
public Pair getLocationForPieceInBoard(ChessPiece[][] board, int id) {
  for (int r = 0; r < BOARD_WIDTH; r++) {
    for (int c = 0; c < BOARD_WIDTH; c++) {
      if (board[r][c] != null && board[r][c].id == id) {
        return new Pair(r, c);
      }
    }
  }
  
  System.out.println("PIECE NOT IN BOARD WITH ID " + id);
  return null;
}


public class Pair {
  int r;
  int c;
  
  public Pair(int r, int c) {
    this.r = r;
    this.c = c;
  }
}
