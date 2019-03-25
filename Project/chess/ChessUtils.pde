static class ChessUtils {
  
  public static ChessPiece[][] copyBoard(ChessPiece[][] board) {
    ChessPiece[][] copy = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        copy[r][c] = board[r][c];
      }
    }
    
    return copy;
  }
  
  public static boolean emptyBetweenColumn(ChessPiece[][] board, Pair spaceA, Pair spaceB) {
    if (spaceA.c != spaceB.c) {
      return false;
    }
    
    int startR = min(spaceA.r, spaceB.r);
    int endR = max(spaceA.r, spaceB.r);
    
    for (int i = startR + 1; i < endR; i++) {
      if (board[i][spaceA.c] != null) {
        return false;
      }
    }
    return true;
  }
  
  public static boolean emptyBetweenRow(ChessPiece[][] board, Pair spaceA, Pair spaceB) {
    if (spaceA.r != spaceB.r) {
      return false;
    }
    
    int startC = min(spaceA.c, spaceB.c);
    int endC = max(spaceA.c, spaceB.c);
    
    for (int i = startC + 1; i < endC; i++) {
      if (board[spaceA.r][i] != null) {
        return false;
      }
    }
    return true;
  }
  
  public static boolean emptyBetweenDiagonal(ChessPiece[][] board, Pair spaceA, Pair spaceB) {
    if (Math.abs(spaceA.r - spaceB.r) != Math.abs(spaceA.c - spaceB.c)) {
        return false;
    }
  
    //down
    if (spaceA.r < spaceB.r) {
      // down left
      if (spaceA.c > spaceB.c) {
        int curR = spaceA.r + 1;
        int curC = spaceA.c - 1;
        while (curR < spaceB.r && curC > spaceB.c) {
          if (board[curR][curC] != null) {
            return false;
          }
          curR += 1;
          curC -= 1;
        }
      }
      else { // down right
        int curR = spaceA.r + 1;
        int curC = spaceA.c + 1;
        while (curR < spaceB.r && curC < spaceB.c) {
          if (board[curR][curC] != null) {
            return false;
          }
          curR += 1;
          curC += 1;
        }
      }
    }
    else { //up 
      // up left
      if (spaceA.c > spaceB.c) {
        int curR = spaceA.r - 1;
        int curC = spaceA.c - 1;
        while (curR > spaceB.r && curC > spaceB.c) {
          if (board[curR][curC] != null) {
            return false;
          }
          curR -= 1;
          curC -= 1;
        }
      }
      else { // up right
        int curR = spaceA.r - 1;
        int curC = spaceA.c + 1;
        while (curR > spaceB.r && curC < spaceB.c) {
          if (board[curR][curC] != null) {
            return false;
          }
          curR -= 1;
          curC += 1;
        }
      }
    }
    return true;
  }
}
