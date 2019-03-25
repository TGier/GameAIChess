class Pawn extends ChessPiece {
  Pawn(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_pawn" : "black_pawn");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    boolean firstMove = (isWhite && r == 6) || (!isWhite && r == 1);
    
    int movingRow = isWhite ? r - 1 : r + 1; // The row the pawn can move into
    int twoSpaceMoveRow = isWhite ? r - 2 : r + 2; // The row the pawn can 2-space move into
    int promotionRow = isWhite ? 0 : BOARD_WIDTH - 1; // The row a pawn promotes in
    ChessPiece[][] boardWithoutPiece = ChessUtils.copyBoard(currentBoard.board);
    boardWithoutPiece[r][c] = null;
    
    // If space in front of pawn is open, allow moving forward
    if (boardWithoutPiece[movingRow][c] == null) {
      // Moving into a sqaure that doesn't promote
      if (movingRow != promotionRow) {
        ChessPiece[][] move = ChessUtils.copyBoard(boardWithoutPiece);
        move[movingRow][c] = this;
        possibleMoves.add(move);
      } else {
        // Move forward into a promotion
        ChessPiece[][] rookPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] knightPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] bishopPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] queenPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        rookPromotion[movingRow][c] = new Rook(this.id, isWhite);
        knightPromotion[movingRow][c] = new Knight(this.id, isWhite);
        bishopPromotion[movingRow][c] = new Bishop(this.id, isWhite);
        queenPromotion[movingRow][c] = new Queen(this.id, isWhite);
        
        possibleMoves.add(rookPromotion);
        possibleMoves.add(knightPromotion);
        possibleMoves.add(bishopPromotion);
        possibleMoves.add(queenPromotion);
      }
    }
      
    // 2-space opener move
    if (firstMove && boardWithoutPiece[movingRow][c] == null && boardWithoutPiece[twoSpaceMoveRow][c] == null) {
      ChessPiece[][] twoSpaceMove = ChessUtils.copyBoard(boardWithoutPiece);
      twoSpaceMove[twoSpaceMoveRow][c] = this;
      possibleMoves.add(twoSpaceMove);
    }
      
    // Left capture
    if (c-1 >= 0 && boardWithoutPiece[movingRow][c-1] != null && boardWithoutPiece[movingRow][c-1].isWhite != this.isWhite) {
      if (movingRow != promotionRow) {
        ChessPiece[][] leftCapture = ChessUtils.copyBoard(boardWithoutPiece);
        leftCapture[movingRow][c-1] = this;
        possibleMoves.add(leftCapture);
      } else {
        // Captures AND promotion!
        ChessPiece[][] rookPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] knightPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] bishopPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] queenPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        rookPromotion[movingRow][c-1] = new Rook(this.id, isWhite);
        knightPromotion[movingRow][c-1] = new Knight(this.id, isWhite);
        bishopPromotion[movingRow][c-1] = new Bishop(this.id, isWhite);
        queenPromotion[movingRow][c-1] = new Queen(this.id, isWhite);
      
        possibleMoves.add(rookPromotion);
        possibleMoves.add(knightPromotion);
        possibleMoves.add(bishopPromotion);
        possibleMoves.add(queenPromotion);
      }
    }
    
    // Right capture
    if (c+1 < BOARD_WIDTH && boardWithoutPiece[movingRow][c+1] != null && boardWithoutPiece[movingRow][c+1].isWhite != this.isWhite) {
      if (movingRow != promotionRow) {
        ChessPiece[][] rightCapture = ChessUtils.copyBoard(boardWithoutPiece);
        rightCapture[movingRow][c+1] = this;
        possibleMoves.add(rightCapture);
      } else {
        // Captures AND promotion!
        ChessPiece[][] rookPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] knightPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] bishopPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        ChessPiece[][] queenPromotion = ChessUtils.copyBoard(boardWithoutPiece);
        rookPromotion[movingRow][c+1] = new Rook(this.id, isWhite);
        knightPromotion[movingRow][c+1] = new Knight(this.id, isWhite);
        bishopPromotion[movingRow][c+1] = new Bishop(this.id, isWhite);
        queenPromotion[movingRow][c+1] = new Queen(this.id, isWhite);
      
        possibleMoves.add(rookPromotion);
        possibleMoves.add(knightPromotion);
        possibleMoves.add(bishopPromotion);
        possibleMoves.add(queenPromotion);
      }
    }
    // TODO En passant?
    
    return possibleMoves;
  }
  
  boolean threatensSpace(ChessPiece[][] board, Pair space) {
    Pair mySpace = getLocationForPieceInBoard(board, this.id);
    if (isWhite) {
      if(space.r == mySpace.r - 1 && Math.abs(mySpace.c - space.c) == 1) {
        //System.out.println("Pawn threatens space " + space.r + "," + space.c);
        return true;
      }
    } else {
      if(space.r == mySpace.r + 1 && Math.abs(mySpace.c - space.c) == 1) {
        //System.out.println("Pawn threatens space " + space.r + "," + space.c);
        return true;
      }
    }
    return false;
  }
}
