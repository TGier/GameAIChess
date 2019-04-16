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

import java.util.Collections;

enum PlayerType {
  HUMAN, // A human player. Must click to make moves
  RANDOM, // An AI that makes totally random moves
  MINIMAX, // An AI that uses a Minimax with Alpha-Beta-Pruning strategy
  MCTS,  // An AI that uses basic MCTS
  MCTS_PB // An AI that uses MCTS but includes progressive bias elements when performing selections
}

// MODIFIABLE VALUES!!! Feel free to change these up to see how it affects the AI. IF something breaks, it's not on us :P
PlayerType whitePlayer = PlayerType.MINIMAX;
PlayerType blackPlayer = PlayerType.MCTS;
int MINIMAX_DEPTH = 5;
boolean MCTS_CACHE = false;
int MAX_MCTS_DEPTH = 7; // Maximum depth for EXPLORATION of nodes
// Maximum moves in a playout before determining it as "not a win", used as Chess can theoretically move back and forth a lot
// in cases of players making random moves. Needed the search to have a guaranteed "end"
int MAX_PLAYOUT_MOVES = 70;
// time in MS to run MCTS exploration and simulation. After this time has passed, no NEW playouts will be performed, but the current playout will be allowed to finish
int TIME_PER_MCTS_EXPLORATION = 10000; 

// Game logic values
ChessBoard gameBoard;
boolean whiteMove = true;
boolean gameOver = false;

// Rendering values
static final int BOARD_WIDTH = 8;
static final int GRID_SIZE = 480 / BOARD_WIDTH;
final color LIGHT_SQUARE = color(255, 206, 158);
final color DARK_SQUARE = color(209, 139, 71);
final color LEGAL_MOVE_HIGHLIGHT = color(129, 169, 234, 165);
final color PREVIOUS_MOVE_HIGHTLIGHT = color(255, 255, 0, 165);
ArrayList<Pair> squareHighlights;
String gameStatus = whiteMove ? "White turn" : "Black turn";

// Human player input values
ChessPiece playerSelectedPiece;
ArrayList<ChessPiece[][]> playerLegalMoves;
ChessPiece promotionPiece;
ArrayList<ChessPiece> promotionPieces;

// AI helper values
int WIN_VAL = 100;
MCTSChess mcts;

// Keep track of the number of moves in a game
int moveCount = 0;

void setup() {
  size(480, 540);
  frameRate(30);
  SampleBoards sampleBoards = new SampleBoards();
  
  // MARK: You can load the alternate boards here! Simply change which method from sampleBoards is called
  gameBoard = new ChessBoard(sampleBoards.getDefaultBoard());
  squareHighlights = new ArrayList<Pair>();
  
  promotionPieces = new ArrayList<ChessPiece>();
  promotionPieces.add(new Rook(100, true));
  promotionPieces.add(new Knight(101, true));
  promotionPieces.add(new Bishop(102, true));
  promotionPieces.add(new Queen(103, true));
  promotionPiece = promotionPieces.get(3);
}
 //<>//
void draw() {
  if (gameOver) {
    return;
  }
  
  background(color(150, 150, 150));
  if (frameCount <= 1) {
    gameBoard.draw();
    drawPromotionSelect();
    drawGameStatusText();
    return;
  }
  
  playMove();
  
  gameBoard.draw();
  drawPromotionSelect();
  drawGameStatusText();
}

void drawGameStatusText() { 
  fill(color(0,0,0));
  textSize(14);
  text(gameStatus, 20, 500);
}

void drawPromotionSelect() {
  fill(color(0,0,0));
  textSize(12);
  text("Player Promotion:", 135, 530);
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

// Returns if the game is over and updates the text
void updateGameStatusText() {
  ArrayList<ChessPiece[][]> possibleBoards = gameBoard.getPossibleMoves(whiteMove);
  boolean inCheck = gameBoard.isCurrentBoardInCheck(whiteMove);
  
  gameStatus = whiteMove ? "White move" : "Black move";
  Winner winner = Winner.IN_PROGRESS;
  if (inCheck && possibleBoards.isEmpty()) {
    gameStatus = "CHECKMATE! " + (whiteMove ? "BLACK" : "WHITE") + " WINS!";
    winner = (whiteMove ? Winner.BLACK : Winner.WHITE);
    gameOver = true;
    drawGameStatusText();
  } else if (possibleBoards.isEmpty()) {
    gameStatus = "Stalemate!"; // No legal moves, but not in check
    winner = Winner.STALEMATE;
    gameOver = true;
    drawGameStatusText();
  } else if (inCheck) {
    gameStatus = (whiteMove ? "White move" : "Black move") + ", IN CHECK!";
  }
  
  printStats(winner);
}

boolean isGameOver() {
  ArrayList<ChessPiece[][]> possibleBoards = gameBoard.getPossibleMoves(whiteMove);
  boolean inCheck = gameBoard.isCurrentBoardInCheck(whiteMove);
  if (inCheck && possibleBoards.isEmpty()) {
    return true;
  } else if (possibleBoards.isEmpty()) {
    return true;
  } else {
    return false;
  }
}

void playMove() {
  ArrayList<ChessPiece[][]> possibleBoards = gameBoard.getPossibleMoves(whiteMove);
  gameStatus = whiteMove ? "White move" : "Black move";
  // Check for checkmate or easy stalemate
  //boolean inCheck = gameBoard.isCurrentBoardInCheck(whiteMove);
  boolean gameOver = isGameOver();
  if (gameOver) {
    updateGameStatusText();
    return;
  }
 
  PlayerType currentActor = whiteMove ? whitePlayer : blackPlayer;
  switch (currentActor) {
    case HUMAN:
      checkHumanInput();
      break;
    case RANDOM:
      makeRandomMove(possibleBoards);
      break;
    case MINIMAX:
      makeMinimaxMove(whiteMove, possibleBoards);
      break;
    case MCTS:
      makeMCTSMove(whiteMove, possibleBoards, false);
      break;
    case MCTS_PB:
      makeMCTSMove(whiteMove, possibleBoards, true);
      break;
  }
  if (currentActor != PlayerType.HUMAN) {
    whiteMove = !whiteMove;
    updateMCTS();
    moveCount += 1;
  }
  updateGameStatusText();
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
    playerLegalMoves = gameBoard.getLegalMovesForPiece(playerSelectedPiece, row, col);
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
      // update the game state
      gameBoard.setBoard(cb);
      whiteMove = !whiteMove;
      updateMCTS();
      moveCount += 1;
      
      // Update rendering values
      playerSelectedPiece = null;
      playerLegalMoves.clear();
      squareHighlights.clear();
      return;
    }
  } 
}

public enum Winner {
  WHITE,
  BLACK,
  STALEMATE,
  IN_PROGRESS
}

void printStats(Winner winner) {  
  String winnerStr = "";
  if (winner == Winner.IN_PROGRESS || winner == null) {
    winnerStr = "No winner! Game still in progress!";
  }
  if (winner == Winner.WHITE) {
    winnerStr = "Game over! White wins!";
  }
  if (winner == Winner.BLACK) {
    winnerStr = "Game over! Black wins!";
  }
  if (winner == Winner.STALEMATE) {
    winnerStr = "No winner! Stalemate!";
  }
  
  System.out.println("-------STATS-------");
  System.out.printf("Move #%d%n", moveCount);
  System.out.println(winnerStr);
  System.out.printf("Margin Of Victory: %d%n", ChessUtils.evaluationFunction(gameBoard.board));
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
  
  System.err.println("Piece with id = " + id + " not found in board!");
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

// MARK: move-making functions
  
void makeRandomMove(ArrayList<ChessPiece[][]> possibleBoards) {
  if (possibleBoards.isEmpty()) {
    return;
  }
  gameBoard.setBoard(possibleBoards.get((int) random(possibleBoards.size())));
}

void makeMinimaxMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
  if (possibleBoards.isEmpty()) {
    return;
  }
  gameBoard.setBoard(minimaxBoard(MINIMAX_DEPTH, whiteMove, possibleBoards));
}

void makeMCTSMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards, boolean progBias) {
  if (possibleBoards.isEmpty()) {
    return;
  }
  if (mcts == null || !MCTS_CACHE) {
    mcts = new MCTSChess(gameBoard.board, whiteMove, possibleBoards);
  }
  gameBoard.setBoard(mcts.getBestMove(gameBoard, progBias));
}

// Update the MCTSChess object if we are caching data 
void updateMCTS() {
  if (mcts != null && MCTS_CACHE) {
    mcts.advanceToBoard(gameBoard, whiteMove);
  }
}
