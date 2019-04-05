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

// Setting to TRUE allows the game to be "stepped" by pressing a key instead of time so AI moves can be followed easier
boolean DEBUG = false;

enum PlayerType {
  HUMAN, RANDOM, MINIMAX, MCTS
}

// TO CHANGE PLAYER TYPES, MODIFY THESE VALUES USING THE ENUMS
PlayerType whitePlayer = PlayerType.MINIMAX;
PlayerType blackPlayer = PlayerType.MCTS;

// Game logic values
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

// MINIMAX values
int MINIMAX_DEPTH = 5;
int WIN_VAL = 100;

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
  } //<>//
}

void keyPressed() {
 if (DEBUG) {
   playMove();
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

void playMove() {
  ArrayList<ChessPiece[][]> possibleBoards = gameBoard.getPossibleMoves(whiteMove);
  gameStatus = whiteMove ? "White move" : "Black move";
  // Check for checkmate or easy stalemate
  boolean inCheck = gameBoard.isCurrentBoardInCheck(whiteMove);
  if (inCheck && possibleBoards.isEmpty()) {
    gameStatus = "CHECKMATE! " + (whiteMove ? "BLACK" : "WHITE") + " WINS!";
    gameOver = true;
    drawGameStatusText(gameStatus);
    return;
  } else if (possibleBoards.isEmpty()) {
    gameStatus = "Stalemate!"; // No legal moves, but not in check
    gameOver = true;
    drawGameStatusText(gameStatus);
    return;
  } else if (inCheck) {
    gameStatus = (whiteMove ? "White move" : "Black move") + ", IN CHECK!";
  }
  
  // TODO find better place for this?
  drawGameStatusText(gameStatus);
 
  PlayerType currentActor = whiteMove ? whitePlayer : blackPlayer;
  switch (currentActor) {
    case HUMAN:
      checkHumanInput();
      break;
    case RANDOM:
      makeRandomMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
    case MINIMAX:
      System.out.println("Made minimax move");
      makeMinimaxMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
    case MCTS:
      makeMCTSMove(whiteMove, possibleBoards);
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
      gameBoard.setBoard(cb);
      whiteMove = !whiteMove; 
      playerSelectedPiece = null;
      playerLegalMoves.clear();
      squareHighlights.clear();
      gameBoard.draw();
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

// MARK: move making functions
  
void makeRandomMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
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

void makeMCTSMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
  if (possibleBoards.isEmpty()) {
    return;
  }
  MCTSChess mcts = new MCTSChess(gameBoard.board, whiteMove, possibleBoards);
  gameBoard.setBoard(mcts.getBestMove());
}

// MARK: minimax functions

int evaluationFunction(ChessPiece[][] board) {
  int score = 0;
  for (int r = 0; r < BOARD_WIDTH; r++) {
    for (int c = 0; c < BOARD_WIDTH; c++) {
      ChessPiece piece = board[r][c];
      if (piece != null) {
        score += piece.pointValue * (piece.isWhite ? 1 : -1);
      }
    }
  }
  return score;
}

// A function that does the first layer of minimax and will return the Move made to get the score as opposed to just the value
ChessPiece[][] minimaxBoard(int depth, boolean isWhite, ArrayList<ChessPiece[][]> nextBoards) {
  Collections.shuffle(nextBoards);
  ChessPiece[][] bestMove = nextBoards.get(0);
  float bestValue = evaluationFunction(bestMove);
  float alpha = Float.NEGATIVE_INFINITY;
  float beta = Float.POSITIVE_INFINITY;
    
  for (ChessPiece[][] board : nextBoards) {
    float minimaxVal = minimax(board, depth - 1, !isWhite, alpha, beta);
    if ((isWhite && minimaxVal >= bestValue) || (!isWhite && minimaxVal <= bestValue)) {
      bestValue = minimaxVal;
      bestMove = board;
    }
  }
  return bestMove;
}

// Psuedo code for minimax followed from: https://www.youtube.com/watch?v=l-hh51ncgDI
// For this project, white is the maximizing player in the tree 
float minimax(ChessPiece[][] boardState, int depth, boolean isWhite, float alpha, float beta) {
  // if at the depth, just return board value (May miss winning board states if evaluation is weird when winning state is at the furthest depth out)
  if (depth == 0) {
    return evaluationFunction(boardState);
  }
  
  // Make a temp ChessBoard to wrap the raw board for extra function
  ChessBoard curBoard = new ChessBoard(boardState);
  ArrayList<ChessPiece[][]> moves = curBoard.getPossibleMoves(isWhite);
  boolean selfInCheck = curBoard.isCurrentBoardInCheck(isWhite);
  //boolean opponentInCheck = curBoard.isCurrentBoardInCheck(!isWhite);
  boolean gameIsOver = moves.size() == 0;
  
  // TODO stalemate evaluations?
  
  // If the board is in check for the current player, return the win for the other player
  if (gameIsOver) {
    if (selfInCheck) {
      // We have been checked, return inverted win val
      return WIN_VAL * (isWhite ? -1 : 1);
    } else {
      // Stalemate
      return 0;
    }
  }
  
  // If white, check for max value on white moves, else check for min value on black moves
  if (isWhite) {
    float bestVal = Float.NEGATIVE_INFINITY;
    
    for (ChessPiece[][] move : moves) {
      float potentialValue = minimax(move, depth - 1, false, alpha, beta);
      bestVal = max(bestVal, potentialValue);
      alpha = max(potentialValue, alpha);
      if (potentialValue >= beta) {
        return bestVal;
      }
    }
    return bestVal;
  } else {float bestVal = Float.POSITIVE_INFINITY;
    
    for (ChessPiece[][] move : moves) {
      float potentialValue = minimax(move, depth - 1, true, alpha, beta);
      bestVal = min(bestVal, potentialValue);
      beta = min(potentialValue, beta);
      if (potentialValue <= alpha) {
        return bestVal;
      }
    }
    return bestVal;
  }
}
