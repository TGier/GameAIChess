class King extends ChessPiece {
  boolean hasMoved = false;
  
  King(int id, boolean isWhite) {
    // Technically worth infinite points but both players Kings will always be on the board so does not matter
    super(id, isWhite, 1, isWhite ? "white_king" : "black_king");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessPiece[][] currentBoard, int r, int c) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    ChessPiece[][] boardWithoutPiece = ChessUtils.copyBoard(currentBoard);
    boardWithoutPiece[r][c] = null;
    
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        if (x == 0 && y == 0) {
          continue;
        }
        int newR = r + x;
        int newC = c + y;
        if (0 <= newR && newR < BOARD_WIDTH
          && 0 <= newC && newC < BOARD_WIDTH
          && (boardWithoutPiece[newR][newC] == null || boardWithoutPiece[newR][newC].isWhite != this.isWhite)) {
          ChessPiece[][] move = ChessUtils.copyBoard(boardWithoutPiece);
          move[newR][newC] = this;
          possibleMoves.add(move);
        }
      }
    }
    
    return possibleMoves;
  }
  
  boolean threatensSpace(ChessPiece[][] board, Pair space) {
    Pair mySpace = getLocationForPieceInBoard(board, this.id);
    if (Math.abs(space.r - mySpace.r) <= 1 && Math.abs(space.c - mySpace.c) <= 1) {
      return true;
    }
    return false;
  }
}
