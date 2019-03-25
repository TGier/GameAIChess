class Knight extends ChessPiece {
  Knight(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_knight" : "black_knight");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = ChessUtils.copyBoard(currentBoard.board);
    boardWithoutPiece[r][c] = null;
    
    // TODO might be generating duplicate moves? Shouldn't matter, but may need to address for optimization
    for (int x = 1; x < 3; x++) {
      for (int y = 1; y < 3; y++) {
        if (x == y) {
        continue;
        }
        // +x/+y, +x/-y, -x/+y, -x/-y
        for (int j = -1; j <= 1; j++) {
          for (int k = -1; k <= 1; k++) {
            if (j == 0 || k == 0) {
              continue;
            }
            int newR = r + (x * j);
            int newC = c + (y * k);
            if (0 <= newR && newR < BOARD_WIDTH
              && 0 <= newC && newC < BOARD_WIDTH
              && (boardWithoutPiece[newR][newC] == null || boardWithoutPiece[newR][newC].isWhite != this.isWhite)) {
              ChessPiece[][] move = ChessUtils.copyBoard(boardWithoutPiece);
              move[newR][newC] = this;
              possibleMoves.add(move);
            }
          }
        }
      }
    }
    return possibleMoves;
  }
  
  boolean threatensSpace(ChessPiece[][] board, Pair space) {
    Pair mySpace = getLocationForPieceInBoard(board, this.id);
    for (int x = 1; x < 3; x++) {
      for (int y = 1; y < 3; y++) {
        if (x == y) {
          continue;
        }
        // +x/+y, +x/-y, -x/+y, -x/-y
        for (int j = -1; j <= 1; j++) {
          for (int k = -1; k <= 1; k++) {
            if (j == 0 || k == 0) {
              continue;
            }
            int newR = mySpace.r + (x * j);
            int newC = mySpace.c + (y * k);
            if (newR == space.r && newC == space.c) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }
}
