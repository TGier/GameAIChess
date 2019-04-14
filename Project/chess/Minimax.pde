
// MARK: minimax functions

// A function that does the first layer of minimax and will return the Move made to get the score as opposed to just the value
ChessPiece[][] minimaxBoard(int depth, boolean isWhite, ArrayList<ChessPiece[][]> nextBoards) {
  Collections.shuffle(nextBoards);
  ChessPiece[][] bestMove = nextBoards.get(0);
  float bestValue = ChessUtils.evaluationFunction(bestMove);
  float alpha = Float.NEGATIVE_INFINITY;
  float beta = Float.POSITIVE_INFINITY;
    
  for (ChessPiece[][] board : nextBoards) {
    float minimaxVal = minimax(board, depth - 1, !isWhite, alpha, beta);
    if ((isWhite && minimaxVal >= bestValue) || (!isWhite && minimaxVal <= bestValue)) {
      bestValue = minimaxVal;
      bestMove = board;
    }
  }
  return bestMove;
}

// Psuedo code for minimax followed from: https://www.youtube.com/watch?v=l-hh51ncgDI
// For this project, white is the maximizing player in the tree 
float minimax(ChessPiece[][] boardState, int depth, boolean isWhite, float alpha, float beta) {
  // if at the depth, just return board value (May miss winning board states if evaluation is weird when winning state is at the furthest depth out)
  if (depth == 0) {
    return ChessUtils.evaluationFunction(boardState);
  }
  
  // Make a temp ChessBoard to wrap the raw board for extra function
  ChessBoard curBoard = new ChessBoard(boardState);
  ArrayList<ChessPiece[][]> moves = curBoard.getPossibleMoves(isWhite);
  boolean selfInCheck = curBoard.isCurrentBoardInCheck(isWhite);
  //boolean opponentInCheck = curBoard.isCurrentBoardInCheck(!isWhite);
  boolean gameIsOver = moves.size() == 0;
  
  // If the board is in check for the current player, return the win for the other player
  if (gameIsOver) {
    if (selfInCheck) {
      // We have been checked, return inverted win val
      return WIN_VAL * (isWhite ? -1 : 1);
    } else {
      // Stalemate
      return 0;
    }
  }
  
  // If white, check for max value on white moves, else check for min value on black moves
  if (isWhite) {
    float bestVal = Float.NEGATIVE_INFINITY;
    
    for (ChessPiece[][] move : moves) {
      float potentialValue = minimax(move, depth - 1, false, alpha, beta);
      bestVal = max(bestVal, potentialValue);
      alpha = max(potentialValue, alpha);
      if (potentialValue >= beta) {
        return bestVal;
      }
    }
    return bestVal;
  } else {float bestVal = Float.POSITIVE_INFINITY;
    
    for (ChessPiece[][] move : moves) {
      float potentialValue = minimax(move, depth - 1, true, alpha, beta);
      bestVal = min(bestVal, potentialValue);
      beta = min(potentialValue, beta);
      if (potentialValue <= alpha) {
        return bestVal;
      }
    }
    return bestVal;
  }
}
