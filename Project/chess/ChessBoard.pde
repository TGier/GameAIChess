
class ChessBoard {
  ChessPiece[][] board;
  ArrayList<Pair> moveSquares; // The list of spaces that changed between moves
  
  ChessPiece whiteKing;
  ChessPiece blackKing;
  
  ChessBoard(ChessPiece[][] board) {
    this.moveSquares = new ArrayList<Pair>();
    this.board = board;
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        if (board[r][c] == null) {
          continue;
        }
        
        if (board[r][c].id == WHITE_KING_ID) {
          whiteKing = board[r][c];
        } else if (board[r][c].id == BLACK_KING_ID) {
          blackKing = board[r][c];
        }
      }
    }
  }
  
  void setupPieces() {
    board = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
    
    
    
    whiteKing = board[7][4];
    blackKing = board[0][4];
  }
  
  ChessPiece getPiece(int r, int c, boolean isWhite) {
    ChessPiece p = board[r][c];
    if (p != null && p.isWhite == isWhite) {
      return p;
    }
    return null;
  }
  
  void setBoard(ChessPiece[][] newBoard) {
    this.moveSquares = new ArrayList<Pair>();
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        ChessPiece oldPiece = this.board[r][c];
        ChessPiece newPiece = newBoard[r][c];
        int oldId = oldPiece != null ? oldPiece.id : -1;
        int newId = newPiece != null ? newPiece.id : -1;
        if (oldId != newId) {
          moveSquares.add(new Pair(r, c));
        }
      }
    }
    this.board = newBoard;
  }
  
  ArrayList<ChessPiece[][]> getLegalMovesForPiece(ChessPiece cp, int r, int c) {
    ArrayList<ChessPiece[][]> possibleBoards = cp.getPossibleMoves(this.board, r, c);
    ArrayList<ChessPiece[][]> legalBoards = new ArrayList<ChessPiece[][]>();
    for (ChessPiece[][] cb : possibleBoards) {
      // check for if the move puts our own King in check and filter out illegal moves
      if (!isInCheck(cb, whiteMove)) {
        legalBoards.add(cb);
      }
    }
    return legalBoards;
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(boolean whiteMove) {
    ArrayList<ChessPiece[][]> possibleBoards = new ArrayList<ChessPiece[][]>();
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        if (board[r][c] != null && board[r][c].isWhite == whiteMove) {
          ArrayList<ChessPiece[][]> moves = board[r][c].getPossibleMoves(this.board, r, c);
          if (moves != null) {
            possibleBoards.addAll(moves);
          } 
        }
      }
    }
    
    ArrayList<ChessPiece[][]> legalBoards = new ArrayList<ChessPiece[][]>();
    for (ChessPiece[][] cb : possibleBoards) {
      // check for if the move puts our own King in check and filter out illegal moves
      if (!isInCheck(cb, whiteMove)) {
        legalBoards.add(cb);
      }
    }
    return legalBoards;
  }
  
  // Returns if the King of the given player is in check
  boolean isInCheck(ChessPiece[][] chessBoard, boolean white) {
    Pair kingLocation = getLocationForPieceInBoard(chessBoard, white ? whiteKing.id : blackKing.id);
    if (kingLocation == null) {
      return true;
    }
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        boolean enemyPieceInSpace = chessBoard[r][c] != null && chessBoard[r][c].isWhite != white;
        if (enemyPieceInSpace && chessBoard[r][c].threatensSpace(chessBoard, kingLocation)) {
          return true;
        } 
      }
    }
    return false;
  }
  
  public boolean isCurrentBoardInCheck(boolean white) {
    return isInCheck(this.board, white);
  }
  
  public Pair getLocationForPieceCurrentBoard(int id) {
    return getLocationForPieceInBoard(this.board, id);
  }
  
  void draw() {
    drawBoard();
    for (Pair mv : moveSquares) {
      stroke(0);
      fill(PREVIOUS_MOVE_HIGHTLIGHT);
      rect(mv.c * GRID_SIZE, mv.r * GRID_SIZE, GRID_SIZE, GRID_SIZE);
    }
    for (Pair sq : squareHighlights) {
      stroke(0);
      fill(LEGAL_MOVE_HIGHLIGHT);
      rect(sq.c * GRID_SIZE, sq.r * GRID_SIZE, GRID_SIZE, GRID_SIZE);
    }
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        if (board[r][c] != null) {
          board[r][c].draw(r, c);
        }
      }
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
  
  String toString() {
    String str = "";
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        ChessPiece piece = this.board[r][c];
        str += (piece != null ? piece.id : "n");
      }
    }
    return str;
  }
}
