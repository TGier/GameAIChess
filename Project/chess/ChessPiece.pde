abstract class ChessPiece {
  int id;
  int pointValue;
  boolean isWhite;
  PImage img;
  
  ChessPiece(int id, boolean isWhite, int pts, String imgStr) {
    this.id = id;
    this.isWhite = isWhite;
    this.pointValue = pts;
    this.img = loadImage(imgStr + ".png");
  }
  
  // Returns the list of all squares this piece can move to (TODO - all boards?)
  abstract ArrayList<ChessPiece[][]> getPossibleMoves(ChessPiece[][] currentBoard, int r, int c);
  
  // Returns if this piece can capture a piece on the given space if allowed to move again
  abstract boolean threatensSpace(ChessPiece[][] board, Pair space);
  
  int getPoints() {
    return pointValue; 
  }
  
  void draw(int r, int c) {
    image(img, c * GRID_SIZE, r * GRID_SIZE, GRID_SIZE, GRID_SIZE);
  }
}
