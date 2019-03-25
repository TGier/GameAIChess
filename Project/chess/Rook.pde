class Rook extends ChessPiece {
  Rook(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_rook" : "black_rook");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = ChessUtils.copyBoard(currentBoard.board);
    boardWithoutPiece[r][c] = null;
    
    // while loop to check up, down, left and right
    int rUp = r-1;
    while (rUp >= 0) {
      ChessPiece pieceInSpace = boardWithoutPiece[rUp][c];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = ChessUtils.copyBoard(boardWithoutPiece);
      moveUp[rUp][c] = this;
      possibleMoves.add(moveUp);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      rUp -= 1;
    }
    
    int rDown = r+1;
    while (rDown < BOARD_WIDTH) {
      ChessPiece pieceInSpace = boardWithoutPiece[rDown][c];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveDown = ChessUtils.copyBoard(boardWithoutPiece);
      moveDown[rDown][c] = this;
      possibleMoves.add(moveDown);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      rDown += 1;
    }
    
    int cLeft = c-1;
    while (cLeft >= 0) {
      ChessPiece pieceInSpace = boardWithoutPiece[r][cLeft];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveLeft = ChessUtils.copyBoard(boardWithoutPiece);
      moveLeft[r][cLeft] = this;
      possibleMoves.add(moveLeft);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      cLeft -= 1;
    }
    int cRight = c+1;
    while (cRight < BOARD_WIDTH) {
      ChessPiece pieceInSpace = boardWithoutPiece[r][cRight];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveRight = ChessUtils.copyBoard(boardWithoutPiece);
      moveRight[r][cRight] = this;
      possibleMoves.add(moveRight);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      cRight += 1;
    }
    
    return possibleMoves;
  }
  
  boolean threatensSpace(ChessPiece[][] board, Pair space) {
    Pair mySpace = getLocationForPieceInBoard(board, this.id);
    if (mySpace.r != space.r && mySpace.c != space.c) {
      return false;
    }
    
    if (mySpace.r == space.r) {
      // check columns in between for emptiness
      if(ChessUtils.emptyBetweenRow(board, mySpace, space)){
        //System.out.println("Rook threatens space " + space.r + "," + space.c);
        return true;
      }
    } 
    else if (mySpace.c == space.c) {
      // check rows in between for emptiness
      if(ChessUtils.emptyBetweenColumn(board, mySpace, space)) {
        //System.out.println("Rook threatens space " + space.r + "," + space.c);
        return true;
      }
    }
    
    return false;
  }
}
