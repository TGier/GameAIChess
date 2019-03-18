

/*
- White goes first
- For minimax, white is max
- White is at bottom, moving upwards
- Images are used from wikimedia commons and available under creative commons
*/

ChessBoard gameBoard;
final int BOARD_WIDTH = 8;
final int GRID_SIZE = 480 / BOARD_WIDTH;
final color LIGHT_SQUARE = color(247, 243, 195);
final color DARK_SQUARE = color(96, 72, 5);

enum PlayerType {
  HUMAN, RANDOM, MINIMAX, MCTS
}

boolean whiteMove = true;
PlayerType whitePlayer = PlayerType.HUMAN;
PlayerType blackPlayer = PlayerType.RANDOM;
ChessPiece playerSelectedPiece;


void setup() {
  size(480, 480);
  gameBoard = new ChessBoard();
}

void draw() {
  gameBoard.draw();
  PlayerType currentActor = whiteMove ? whitePlayer : blackPlayer;
  switch (currentActor) {
    case HUMAN:
      break;
    case RANDOM:
      gameBoard.makeRandomMove(whiteMove);
      whiteMove = !whiteMove;
      break;
    case MINIMAX:
      gameBoard.makeMinimaxMove(whiteMove);
      whiteMove = !whiteMove;
      break;
    case MCTS:
      gameBoard.makeMCTSMove(whiteMove);
      whiteMove = !whiteMove;
      break;
  }
  // TODO
  // Check for checkmate
}

// MARK: ChessBoard

class ChessBoard {
  ArrayList<ChessPiece> whitePieces;
  ArrayList<ChessPiece> blackPieces;
  
  ChessBoard() {
    setupPieces();
  }
  
  void setupPieces() {
    whitePieces = new ArrayList<ChessPiece>();
    blackPieces = new ArrayList<ChessPiece>();
    
    // White board setup
    whitePieces.add(new Rook(7, 0, true));
    whitePieces.add(new Knight(7, 1, true));
    whitePieces.add(new Bishop(7, 2, true));
    whitePieces.add(new Queen(7, 3, true));
    whitePieces.add(new King(7, 4, true));
    whitePieces.add(new Bishop(7, 5, true));
    whitePieces.add(new Knight(7, 6, true));
    whitePieces.add(new Rook(7, 7, true));
    whitePieces.add(new Pawn(6, 0, true));
    whitePieces.add(new Pawn(6, 1, true));
    whitePieces.add(new Pawn(6, 2, true));
    whitePieces.add(new Pawn(6, 3, true));
    whitePieces.add(new Pawn(6, 4, true));
    whitePieces.add(new Pawn(6, 5, true));
    whitePieces.add(new Pawn(6, 6, true));
    whitePieces.add(new Pawn(6, 7, true));
    
    // Black board setup
    blackPieces.add(new Rook(0, 0, false));
    blackPieces.add(new Knight(0, 1, false));
    blackPieces.add(new Bishop(0, 2, false));
    blackPieces.add(new Queen(0, 3, false));
    blackPieces.add(new King(0, 4, false));
    blackPieces.add(new Bishop(0, 5, false));
    blackPieces.add(new Knight(0, 6, false));
    blackPieces.add(new Rook(0, 7, false));
    blackPieces.add(new Pawn(1, 0, false));
    blackPieces.add(new Pawn(1, 1, false));
    blackPieces.add(new Pawn(1, 2, false));
    blackPieces.add(new Pawn(1, 3, false));
    blackPieces.add(new Pawn(1, 4, false));
    blackPieces.add(new Pawn(1, 5, false));
    blackPieces.add(new Pawn(1, 6, false));
    blackPieces.add(new Pawn(1, 7, false));
  }
  
  void makeRandomMove(boolean whiteMove) {
    // TODO
  }
  
  void makeMinimaxMove(boolean whiteMove) {
    // TODO
  }
  
  void makeMCTSMove(boolean whiteMove) {
    // TODO
  }
  
  int evalBoard() {
    int boardScore = 0;
    for (ChessPiece wp : whitePieces) {
      boardScore += wp.getPoints();
    }
    for (ChessPiece bp : blackPieces) {
      boardScore -= bp.getPoints();
    }
    return boardScore;
  }
  
  void draw() {
    drawBoard();
    // TODO color squares of valid moves for player?
    for (ChessPiece wp : whitePieces) {
      wp.draw();
    }
    for (ChessPiece bp : blackPieces) {
      bp.draw();
    }
  }
  
  void drawBoard() {
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        noStroke();
        if (r % 2 == c % 2) {
          fill(LIGHT_SQUARE);
        } else {
          fill(DARK_SQUARE);
        }
        rect(c * GRID_SIZE, r * GRID_SIZE, GRID_SIZE, GRID_SIZE);
      }
    }
  }
}

// MARK: Chess pieces

abstract class ChessPiece {
  int r;
  int c;
  int pointValue;
  boolean isWhite;
  PImage img;
  
  ChessPiece(int row, int col, boolean isWhite, int pts, String imgStr) {
    this.r = row;
    this.c = col;
    this.isWhite = isWhite;
    this.pointValue = pts;
    this.img = loadImage(imgStr + ".png");
  }
  
  // Returns the list of all squares this piece can move to
  abstract ArrayList<Pair> getPossibleMoves(ChessBoard currentBoard);
  
  // Returns if this piece can capture the given chess piece if allowed to move again
  boolean canCapture(ChessBoard board, ChessPiece other) {
    ArrayList<Pair> moves = getPossibleMoves(board);
    // TODO
    return false;
  }
  
  int getPoints() {
    return pointValue; 
  }
  
  void draw() {
    image(img, c * GRID_SIZE, r * GRID_SIZE, GRID_SIZE, GRID_SIZE);
  }
}

class Pawn extends ChessPiece {
  Pawn(int r, int c, boolean isWhite) {
    super(r, c, isWhite, 1, isWhite ? "white_pawn" : "black_pawn");
  }
  
  ArrayList<Pair> getPossibleMoves(ChessBoard currentBoard) {
    // TODO
    return null;
  }
}

class Rook extends ChessPiece {
  Rook(int r, int c, boolean isWhite) {
    super(r, c, isWhite, 1, isWhite ? "white_rook" : "black_rook");
  }
  
  ArrayList<Pair> getPossibleMoves(ChessBoard currentBoard) {
    // TODO
    return null;
  }
}

class Knight extends ChessPiece {
  Knight(int r, int c, boolean isWhite) {
    super(r, c, isWhite, 1, isWhite ? "white_knight" : "black_knight");
  }
  
  ArrayList<Pair> getPossibleMoves(ChessBoard currentBoard) {
    // TODO
    return null;
  }
}

class Bishop extends ChessPiece {
  Bishop(int r, int c, boolean isWhite) {
    super(r, c, isWhite, 1, isWhite ? "white_bishop" : "black_bishop");
  }
  
  ArrayList<Pair> getPossibleMoves(ChessBoard currentBoard) {
    // TODO
    return null;
  }
}

class Queen extends ChessPiece {
  Queen(int r, int c, boolean isWhite) {
    super(r, c, isWhite, 1, isWhite ? "white_queen" : "black_queen");
  }
  
  ArrayList<Pair> getPossibleMoves(ChessBoard currentBoard) {
    // TODO
    return null;
  }
}

class King extends ChessPiece {
  King(int r, int c, boolean isWhite) {
    super(r, c, isWhite, 1, isWhite ? "white_king" : "black_king");
  }
  
  ArrayList<Pair> getPossibleMoves(ChessBoard currentBoard) {
    // TODO
    return null;
  }
}

class Pair {
  int r;
  int c;
}