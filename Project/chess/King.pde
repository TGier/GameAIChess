class King extends ChessPiece {
  King(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_king" : "black_king");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = ChessUtils.copyBoard(currentBoard.board);
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
    
    // TODO castling?
    return possibleMoves;
  }
  
  boolean threatensSpace(ChessPiece[][] board, Pair space) {
    Pair mySpace = getLocationForPieceInBoard(board, this.id);
    if (Math.abs(space.r - mySpace.r) <= 1 && Math.abs(space.c - mySpace.c) <= 1) {
      //System.out.println("King threatens space " + space.r + "," + space.c);
      return true;
    }
    return false;
  }
}
