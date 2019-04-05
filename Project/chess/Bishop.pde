class Bishop extends ChessPiece {
  Bishop(int id, boolean isWhite) {
    super(id, isWhite, 3, isWhite ? "white_bishop" : "black_bishop");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessPiece[][] currentBoard, int r, int c) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    ChessPiece[][] boardWithoutPiece = ChessUtils.copyBoard(currentBoard);
    boardWithoutPiece[r][c] = null;
    
    // while loop to check up-left, up-right, down-left, down-right
    int rUp = r-1;
    int cLeft = c-1;
    while (rUp >= 0 && cLeft >= 0) {
      ChessPiece pieceInSpace = boardWithoutPiece[rUp][cLeft];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = ChessUtils.copyBoard(boardWithoutPiece);
      moveUp[rUp][cLeft] = this;
      possibleMoves.add(moveUp);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      rUp -= 1;
      cLeft -= 1;
    }
    
    rUp = r-1;
    int cRight = c+1;
    while (rUp >= 0 && cRight < BOARD_WIDTH) {
      ChessPiece pieceInSpace = boardWithoutPiece[rUp][cRight];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = ChessUtils.copyBoard(boardWithoutPiece);
      moveUp[rUp][cRight] = this;
      possibleMoves.add(moveUp);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      rUp -= 1;
      cRight += 1;
    }
    
    int rDown = r+1;
    cLeft = c-1;
    while (rDown < BOARD_WIDTH && cLeft >= 0) {
      ChessPiece pieceInSpace = boardWithoutPiece[rDown][cLeft];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = ChessUtils.copyBoard(boardWithoutPiece);
      moveUp[rDown][cLeft] = this;
      possibleMoves.add(moveUp);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      rDown += 1;
      cLeft -= 1;
    }
    
    rDown = r+1;
    cRight = c+1;
    while (rDown < BOARD_WIDTH && cRight < BOARD_WIDTH) {
      ChessPiece pieceInSpace = boardWithoutPiece[rDown][cRight];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = ChessUtils.copyBoard(boardWithoutPiece);
      moveUp[rDown][cRight] = this;
      possibleMoves.add(moveUp);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      rDown += 1;
      cRight += 1;
    }
    
    return possibleMoves;
  }
  
  boolean threatensSpace(ChessPiece[][] board, Pair space) {
    Pair mySpace = getLocationForPieceInBoard(board, this.id);
    if(ChessUtils.emptyBetweenDiagonal(board, mySpace, space)) {
      return true;
    }
    return false;
  }
}
