/* Wrapper for the MCTS logic for our chess game
 * Resources we used when researching MCTS and evaluation functions:
 * - http://mcts.ai/about/index.html
 * - https://www.youtube.com/watch?v=lhFXKNyA0QA
 * - https://www.geeksforgeeks.org/ml-monte-carlo-tree-search-mcts/
 * - http://www.ke.tu-darmstadt.de/lehre/arbeiten/bachelor/2012/Arenz_Oleg.pdf
 *
 * NOTE:
 * 1) We determine a given playout is "uninteresting" at 100 random moves. This is to keep the game from pigeon-holing on 1 playthrough as we don't have some of the less common stalemate/draw rules
 * 2) When we explore from a node, we add all the valid children instead of just a single one. This is done as we wanted to avoid spending time determining if a randomly chosen new child was already considered
 */

 
// MCTS values used to help make the AI more playable and faster
int MAX_MCTS_DEPTH = 7; // Maximum depth for EXPLORATION of nodes
// Maximum moves in a playout before determining it as "not a win", used as Chess can theoretically move back and forth a lot in cases of players making random moves. Needed the search to have a guaranteed "end"
int MAX_PLAYOUT_MOVES = 70;
int TIME_PER_MCTS_EXPLORATION = 10000; // time in MS to run MCTS exploration and simulation. After this time has passed, no NEW playouts will be performed, but the current playout will be allowed to finish

 
public class MCTSChess {
  TreeNode root;
  
  MCTSChess(ChessPiece[][] board, boolean whiteMove, ArrayList<ChessPiece[][]> possibleNextMoves) {
    this.root = new TreeNode(board, whiteMove, possibleNextMoves);
  }
  
  ChessPiece[][] getBestMove(ChessBoard cb, boolean progBias) {
    if (!root.board.toString().equals(cb.toString())) {
      System.err.println("ERROR: Attempting to get move from a board that is not the same as the current root");
      return null;
    } 
    
    long startTime = System.currentTimeMillis();
   
    // MCTS is able to be stopped at any time. We wanted to let the AI have time to playout games but also limit it so the AI is relatively quick to play
    while (System.currentTimeMillis() < (startTime + TIME_PER_MCTS_EXPLORATION)) {
      // Selection and Expansion
      TreeNode selectedNode = root.selectAndExpand(root.isWhite, MAX_MCTS_DEPTH, progBias);
    
      // Playout on selected node
      Pair val = selectedNode.playout(root.isWhite);
    
      // Back propagation of the playout result to parents of the source of the playout
      selectedNode.backPropagate(val);
    }
    
    // Select child of root that has the most simulations. MCTS should do the most playouts from the most interesting move
    return root.selectMove().board;
  }
  
  void advanceToBoard(ChessBoard board, boolean whiteMove) {
    if (board.toString().equals(root.board.toString())) {
      return;
    }
    
    TreeNode nextRoot = null;
    for (TreeNode n : root.children) {
      if (board.toString().equals(n.board.toString()) && n.isWhite == whiteMove) {
        //System.out.println("Found child node with same board and current acting player. Using that...");
        nextRoot = n;
        break;
      }
    }
    
    if (nextRoot == null) {
      //System.err.println("Couldn't find child to advance root to! Reseting training data...");
      root = new TreeNode(board.board, whiteMove);
    }
    this.root = nextRoot;
  }
}

class TreeNode {
  ChessBoard board;
  ArrayList<TreeNode> children; // a list of all child tree nodes
  TreeNode parent; // for back propogation
  
  boolean isWhite; // If this tree node represents a board for white to make a move on
  int whiteWins = 0; // The number of white wins found in playouts from this node
  int blackWins = 0; // The number of black wins found in playouts from this node
  int simulations = 0; // the number of simulations run
  
  TreeNode(ChessPiece[][] board, boolean whiteMove) {
    this.board = new ChessBoard(board);
    this.isWhite = whiteMove;
    children = new ArrayList<TreeNode>();
  }
  
  TreeNode(ChessPiece[][] board, boolean whiteMove, ArrayList<ChessPiece[][]> childBoards) {
    this.board = new ChessBoard(board);
    this.isWhite = whiteMove;
    children = new ArrayList<TreeNode>();
    
    for (ChessPiece[][] cb : childBoards) {
      TreeNode child = new TreeNode(cb, !whiteMove);
      child.parent = this;
      children.add(child);
    }
  }
  
  float getValue(boolean whiteMove, boolean progBias) {
    float c = 2;
    float k = 3;
    float epsilon = 1;
    
    // wins + c * sqrt(2 * ln(parent.simulations) / (epsilon + simulations))
    float value = (whiteMove ? whiteWins : blackWins) + c * sqrt(2 * log(1 + parent.simulations) / (epsilon + simulations));
    if (progBias) {
      // k * H(board) / (epsilon + simulations) 
      value += (k * getBoardHeuristic(whiteMove) / (epsilon + simulations));
    }
    return value;
  }
  
  float getBoardHeuristic(boolean whiteMove) {
    // We want this to be positive if good for current player, but eval returns negative when good for black, so invert it
    return ChessUtils.evaluationFunction(this.board.board) * (whiteMove ? 1 : -1);
  }
  
  TreeNode selectAndExpand(boolean whiteMove, int depth, boolean progBias) {
    // If at max depth, select this node
    if (depth == 0) {
      return this;
    }
    
    // If no children and not at max depth, EXPAND
    if (children.isEmpty()) {
      this.expandTree();
      // If unable to expand, we are a terminal node, return self
      if (this.children.isEmpty()) {
        return this;
      }
      // We did expansion, we should select an immediate child
      depth = 1;
    }
    
    // traverse the tree choosing the "best" child (exploitation v exploration) until you hit max depth or a node with no children
    Collections.shuffle(this.children);
    TreeNode bestChild = this.children.get(0);
    float bestValue = this.children.get(0).getValue(whiteMove, progBias);
    
    for (TreeNode tn : children) {
      float childVal = tn.getValue(whiteMove, progBias);
      if (bestChild == null || bestValue < childVal) {
        bestChild = tn;
        bestValue = childVal;
      }
    }
    return bestChild.selectAndExpand(whiteMove, depth - 1, progBias);  
  }
  
  void expandTree() {
    // expand the tree with all possible children
    ArrayList<ChessPiece[][]> childBoards = this.board.getPossibleMoves(isWhite);
    for (ChessPiece[][] cb : childBoards) {
      TreeNode child = new TreeNode(cb, !isWhite);
      child.parent = this;
      children.add(child);
    }
  }
  
  // Returns a Pair of (whiteWin, blackWin)
  Pair playout(boolean whiteWins) {
    // play out a game from this board making random moves
    boolean curWhite = this.isWhite;
    ChessBoard curBoard = new ChessBoard(this.board.board);
    int moveCount = 0;
    
    // only go X moves deep in a playout before deciding it was 
    while (moveCount < MAX_PLAYOUT_MOVES) {      
      // Get a random legal move
      ArrayList<ChessPiece[][]> legalMoves = curBoard.getPossibleMoves(curWhite);
      
      // Check if the game is over (no legal moves to playout, then determine if a "win" for the correct player)
      // If end state, return the win pair
      if (legalMoves.isEmpty()) {
        // Hit a case of no legal moves
        if (whiteWins && curBoard.isCurrentBoardInCheck(false)) {
          // Playout found checkmate win for white
          // We are tracking white wins and black is in checkmate
          return new Pair(1, 0);
        } else if (!whiteWins && curBoard.isCurrentBoardInCheck(true)) {
          // Playout found checkmate win for black
          // We are tracking black wins and white is in checkmate
          return new Pair(0, 1);
        }
        //System.out.println("Playout found stalemate or a checkmate loss...");
        return new Pair(0, 0);
      }
      
      // else, try next move
      ChessPiece[][] move = legalMoves.get(int(random(legalMoves.size())));
      curBoard.setBoard(move);
      curWhite = !curWhite;
      moveCount++;
    }
    
    return new Pair(0, 0);
  }
  
  void backPropagate(Pair val) {
    this.whiteWins += val.r;
    this.blackWins += val.c;
    this.simulations += 1;
    if (this.parent != null) {
      parent.backPropagate(val);
    }
  }
  
  ChessBoard selectMove() {
    Collections.shuffle(children);
    TreeNode bestChild = children.get(0);
    int mostSims = bestChild.simulations;
    
    for (TreeNode tn : children) {
      if (bestChild == null || mostSims < tn.simulations) {
        bestChild = tn;
        mostSims = tn.simulations;
      }
    }
    return bestChild.board;
  }
}
