/* Wrapper for the MCTS logic for our chess game
 * Resources we used when researching MCTS:
 * - http://mcts.ai/about/index.html
 * - https://www.youtube.com/watch?v=lhFXKNyA0QA
 * - https://www.geeksforgeeks.org/ml-monte-carlo-tree-search-mcts/
 *
 * NOTE:
 * 1) We determine a given playout is "uninteresting" at 100 random moves. This is to keep the game from pigeon-holing on 1 playthrough as we don't have some of the less common stalemate/draw rules
 * 2) When we explore from a node, we add all the valid children instead of just a single one. This is done as we wanted to avoid spending time determining if a randomly chosen new child was already considered
 */
 
 /*
 ~~~~~~~~~~~~~~ NOTES TO IMPROVE THIS
   1) Try to optmization stuff at the bottom of this file to reuse previous runs. It's wasteful to redo previous explorations when we can potentially carry data over
     Plus, MCTS gets better the more simulations it can run
   2) Adjust the selection formula when selecting to explore (we may want to explore nodes we win on a lot over nodes we haven't looked at)
 
 */
 
 
 // MCTS values used to help make the AI more playable and faster
int MAX_MCTS_DEPTH = 4; // Maximum depth for EXPLORATION of nodes
// Maximum moves in a playout before determining it as "not a win", used as Chess can theoretically move back and forth a lot in cases of players making random moves. Needed the search to have a guaranteed "end"
int MAX_PLAYOUT_MOVES = 100;
int TIME_PER_MCTS_EXPLORATION = 10000; // time in MS to run MCTS exploration and simulation. After this time has passed, no NEW playouts will be performed, but the current playout will be allowed to finish

 
public class MCTSChess {
  TreeNode root;
  
  MCTSChess(ChessPiece[][] board, boolean whiteMove, ArrayList<ChessPiece[][]> possibleNextMoves) {
    this.root = new TreeNode(board, whiteMove, possibleNextMoves);
  }
  
  ChessPiece[][] getBestMove() {
    System.out.println("Starting MCTS to select move: " + (root.isWhite ? "white" : "black"));
    long startTime = System.currentTimeMillis();
   
    // MCTS is able to be stopped at any time. We wanted to let the AI have time to playout games but also limit it so the AI is relatively quick to play
    while (System.currentTimeMillis() < (startTime + TIME_PER_MCTS_EXPLORATION)) {
      // Selection and Expansion
      TreeNode selectedNode = root.selectAndExpand(MAX_MCTS_DEPTH);
    
      // Playout on selected node
      int val = selectedNode.playout(root.isWhite);
    
      // Back propagation of the playout result to parents of the source of the playout
      selectedNode.backPropagate(val);
      //System.out.println("Playout completed");
    }
    
    // Select child of root that has the most simulations. MCTS should do the most playouts from the most interesting move
    System.out.printf("MCTS Move selected after %d ms. Total simulations: %d, Total wins: %d\n", System.currentTimeMillis() - startTime, root.simulations, root.wins);
    return root.selectMove().board;
  }
}

class TreeNode {
  ChessBoard board;
  ArrayList<TreeNode> children; // a list of all child tree nodes
  TreeNode parent; // for back propogation
  
  boolean isWhite; // If this tree node represents a board for white to make a move on
  int wins = 0; // The estimated value based on playouts. A win is 1, anything else is 0
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
  
  float getValue() {
    // TODO tune these values
    float c = 1.5;
    float epsilon = 0.1;
    
    // val + c * sqrt(ln(parent.simulations) / (epsilon + simulations))
    return wins + c * sqrt(log(parent.simulations) / (epsilon + simulations));
  }
  
  TreeNode selectAndExpand(int depth) {
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
    float bestValue = this.children.get(0).getValue();
    
    for (TreeNode tn : children) {
      float childVal = tn.getValue();
      if (bestChild == null || bestValue < childVal) {
        bestChild = tn;
        bestValue = childVal;
      }
    }
    return bestChild.selectAndExpand(depth - 1);  
  }
  
  void expandTree() {
    // TODO expand the tree with all possible children
    ArrayList<ChessPiece[][]> childBoards = this.board.getPossibleMoves(isWhite);
    for (ChessPiece[][] cb : childBoards) {
      TreeNode child = new TreeNode(cb, !isWhite);
      child.parent = this;
      children.add(child);
    }
  }
  
  int playout(boolean whiteWins) {
    // play out a game from this board making random moves
    boolean curWhite = this.isWhite;
    ChessBoard curBoard = new ChessBoard(this.board.board);
    int moveCount = 0;
    
    // only go X moves deep in a playout before deciding it was 
    while (moveCount < MAX_PLAYOUT_MOVES) {      
      // Get a random legal move
      ArrayList<ChessPiece[][]> legalMoves = curBoard.getPossibleMoves(curWhite);
      
      // check if the game is over (no legal moves to playout, then determine if a "win" for the correct player)
      // If end state, return 1 or 0
      if (legalMoves.isEmpty()) {
        // Hit a case of no legal moves
        if (whiteWins && curBoard.isCurrentBoardInCheck(false)) {
          // We are tracking white wins and black is in checkmate
          //System.out.println("Playout found checkmate win for white!");
          return 1;
        } else if (!whiteWins && curBoard.isCurrentBoardInCheck(true)) {
          //System.out.println("Playout found checkmate win for black!");
          // We are tracking black wins and white is in checkmate
          return 1;
        }
        //System.out.println("Playout found stalemate or a checkmate loss...");
        return 0;
      }
      
      // else, try next move
      ChessPiece[][] move = legalMoves.get(int(random(legalMoves.size())));
      curBoard.setBoard(move);
      curWhite = !curWhite;
      moveCount++;
    }
    
    //System.out.printf("Playout exceeded %d moves. Determined as a loss.\n", MAX_PLAYOUT_MOVES);
    return 0;
  }
  
  void backPropagate(int val) {
    this.wins += val;
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
    System.out.printf("Selected move with %d wins of %d simulations\n", bestChild.wins, bestChild.simulations);
    return bestChild.board;
  }
}


/*
  Optimization idea:
  1) When selecting a move, update the root of the MCTSChess object to be the selected node
  2) This will take care of switching the color as color is tied to the nodes
  3) When running playouts, return a pair of ints (white win, black win) and propogate up
  4) Update eval function to care about white vs black as a param when called
*/
