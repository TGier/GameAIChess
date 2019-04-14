static final int WHITE_KING_ID = 5;
static final int BLACK_KING_ID = 21;
  
// Sample chess boards.
public class SampleBoards {
  
  public ChessPiece[][] getDefaultBoard() {
    ChessPiece[][] board = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
    // White board setup
    board[7][0] = new Rook(1, true);
    board[7][1] = new Knight(2, true);
    board[7][2] = new Bishop(3, true);
    board[7][3] = new Queen(4, true);
    board[7][4] = new King(WHITE_KING_ID, true);
    board[7][5] = new Bishop(6, true);
    board[7][6] = new Knight(7, true);
    board[7][7] = new Rook(8, true);
    board[6][0] = new Pawn(9, true);
    board[6][1] = new Pawn(10, true);
    board[6][2] = new Pawn(11, true);
    board[6][3] = new Pawn(12, true);
    board[6][4] = new Pawn(13, true);
    board[6][5] = new Pawn(14, true);
    board[6][6] = new Pawn(15, true);
    board[6][7] = new Pawn(16, true);
    
    // Black board setup
    board[0][0] = new Rook(17, false);
    board[0][1] = new Knight(18, false);
    board[0][2] = new Bishop(19, false);
    board[0][3] = new Queen(20, false);
    board[0][4] = new King(BLACK_KING_ID, false);
    board[0][5] = new Bishop(22, false);
    board[0][6] = new Knight(23, false);
    board[0][7] = new Rook(24, false);
    board[1][0] = new Pawn(25, false);
    board[1][1] = new Pawn(26, false);
    board[1][2] = new Pawn(27, false);
    board[1][3] = new Pawn(28, false);
    board[1][4] = new Pawn(29, false);
    board[1][5] = new Pawn(30, false);
    board[1][6] = new Pawn(31, false);
    board[1][7] = new Pawn(32, false);
    
    return board;
  }

  public ChessPiece[][] getCheckmateInTwoSample1() {
    ChessPiece[][] mateInTwoSample1 = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
    // White board setup
    mateInTwoSample1[6][4] = new Bishop(3, true);
    mateInTwoSample1[1][5] = new Queen(4, true);
    mateInTwoSample1[5][4] = new King(WHITE_KING_ID, true);
    mateInTwoSample1[4][4] = new Pawn(9, true);
    mateInTwoSample1[5][1] = new Pawn(10, true);
    mateInTwoSample1[6][2] = new Pawn(11, true);
    
    // Black board setup
    mateInTwoSample1[2][3] = new Queen(20, false);
    mateInTwoSample1[2][2] = new King(BLACK_KING_ID, false);
    mateInTwoSample1[2][6] = new Knight(23, false);
    mateInTwoSample1[3][0] = new Pawn(25, false);
    mateInTwoSample1[2][1] = new Pawn(26, false);
    mateInTwoSample1[3][4] = new Pawn(27, false);
    return mateInTwoSample1;
  }
  
  public ChessPiece[][] getExampleBoard1() {
    ChessPiece[][] board = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
    
    // White board setup
    board[3][3] = new Bishop(4, true);
    board[7][4] = new King(WHITE_KING_ID, true);
    board[1][7] = new Rook(3, true);
    
    // Black board setup
    board[0][0] = new Rook(17, false);
    board[0][4] = new King(BLACK_KING_ID, false);
    
    return board;
  } 

}
