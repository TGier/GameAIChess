
class ChessBoard {
  ChessPiece[][] board;
  
  ChessPiece whiteKing;
  ChessPiece blackKing;
  
  ChessBoard() {
    setupPieces();
  }
  
  void setupPieces() {
    board = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
    
    // White board setup
    board[7][0] = new Rook(1, true);
    board[7][1] = new Knight(2, true);
    board[7][2] = new Bishop(3, true);
    board[7][3] = new Queen(4, true);
    board[7][4] = new King(5, true);
    board[7][5] = new Bishop(6, true);
    board[7][6] = new Knight(7, true);
    board[7][7] = new Rook(8, true);
    board[6][0] = new Pawn(9, true);
    board[6][1] = new Pawn(10, true);
    board[6][2] = new Pawn(11, true);
    board[6][3] = new Pawn(12, true);
    board[6][4] = new Pawn(13, true);
    board[6][5] = new Pawn(14, true);
    board[6][6] = new Pawn(15, true);
    board[6][7] = new Pawn(16, true);
    
    // Black board setup
    board[0][0] = new Rook(17, false);
    board[0][1] = new Knight(18, false);
    board[0][2] = new Bishop(19, false);
    board[0][3] = new Queen(20, false);
    board[0][4] = new King(21, false);
    board[0][5] = new Bishop(22, false);
    board[0][6] = new Knight(23, false);
    board[0][7] = new Rook(24, false);
    board[1][0] = new Pawn(25, false);
    board[1][1] = new Pawn(26, false);
    board[1][2] = new Pawn(27, false);
    board[1][3] = new Pawn(28, false);
    board[1][4] = new Pawn(29, false);
    board[1][5] = new Pawn(30, false);
    board[1][6] = new Pawn(31, false);
    board[1][7] = new Pawn(32, false);
    
    
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
    // TODO reset stalemate conditions?
    board = newBoard;
  }
  
  ArrayList<ChessPiece[][]> getLegalMovesForPiece(ChessPiece cp) {
    ArrayList<ChessPiece[][]> possibleBoards = cp.getPossibleMoves(this);
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
          ArrayList<ChessPiece[][]> moves = board[r][c].getPossibleMoves(this);
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
    // TODO filter any moves that have the <whiteMove> King in check
    Pair kingLocation = getLocationForPieceInBoard(chessBoard, white ? whiteKing.id : blackKing.id);
    if (kingLocation == null) {
      return true; //TODO filter out king captures instead?
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
  
  void makeRandomMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
    if (possibleBoards.isEmpty()) {
      return;
    }
    board = possibleBoards.get((int) random(possibleBoards.size()));
  }
  
  void makeMinimaxMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
    // TODO
  }
  
  void makeMCTSMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
    // TODO
  }
  
  public Pair getLocationForPieceCurrentBoard(int id) {
    return getLocationForPieceInBoard(this.board, id);
  }
  
  int evalBoard() {
    int boardScore = 0;
    // TODO
    return boardScore;
  }
  
  void draw() {
    drawBoard();
    for (Pair sq : squareHighlights) {
      stroke(0);
      fill(129, 169, 234);
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
}
