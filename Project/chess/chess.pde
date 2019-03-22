

/*
- White goes first
- For minimax, white is max
- White is at bottom, moving upwards
- Images are used from wikimedia commons and available under creative commons
*/

/*
DRAW RULES
- 6 repeated board states (3 pairs of board states) non-successive
- 50 moves without advancing a pawn or capturing a piece
- No legal moves for a player, but King is not in check - CHECK (is done)
*/

boolean DEBUG = false;

ChessBoard gameBoard;
final int BOARD_WIDTH = 8;
final int GRID_SIZE = 480 / BOARD_WIDTH;
final color LIGHT_SQUARE = color(247, 243, 195);
final color DARK_SQUARE = color(96, 72, 5);

enum PlayerType {
  HUMAN, RANDOM, MINIMAX, MCTS
}

boolean whiteMove = true;
boolean gameOver = false;
PlayerType whitePlayer = PlayerType.RANDOM;
PlayerType blackPlayer = PlayerType.RANDOM;
ChessPiece playerSelectedPiece;

void setup() {
  size(480, 520);
  frameRate(10);
  gameBoard = new ChessBoard();
}

void drawGameStatusText(String text) { 
  fill(color(0,0,0));
  text(text, 20, 500);
}

void draw() {
  if (gameOver) {
    return;
  }
  background(color(150, 150, 150));
  gameBoard.draw();
  
  if (!DEBUG) {
    playMove();
  } //<>//
}

void keyPressed() {
 if (DEBUG) {
   playMove();
 }
}

void playMove() {
  ArrayList<ChessPiece[][]> possibleBoards = gameBoard.getPossibleMoves(whiteMove);
  String gameStatus = whiteMove ? "White turn" : "Black turn";
  // Check for checkmate
  System.out.println("IGNORE RIGHT BELOW HERE, CHRIS");
  if (gameBoard.isCurrentBoardInCheck(whiteMove) && possibleBoards.isEmpty()) {
    gameStatus = "CHECKMATE! " + (whiteMove ? "BLACK" : "WHITE") + " WINS!";
    drawGameStatusText(gameStatus);
    gameOver = true;
    return;
  } if (possibleBoards.isEmpty()) {
    drawGameStatusText("Stalemate. No legal moves, but not in check: " + (whiteMove ? "WHITE" : "BLACK"));
    gameOver = true;
    return;
  }
  
  drawGameStatusText(gameStatus);
 
  PlayerType currentActor = whiteMove ? whitePlayer : blackPlayer;
  switch (currentActor) {
    case HUMAN:
      break;
    case RANDOM:
      gameBoard.makeRandomMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
    case MINIMAX:
      gameBoard.makeMinimaxMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
    case MCTS:
      gameBoard.makeMCTSMove(whiteMove, possibleBoards);
      whiteMove = !whiteMove;
      break;
  }
  System.out.println("~~~~ turn over ~~~~");}

// MARK: ChessBoard

class ChessBoard {
  ChessPiece[][] board;
  
  ChessPiece whiteKing;
  ChessPiece blackKing;
  
  ChessBoard() {
    setupPieces();
  }
  
  void setupPieces() {
    board = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
    
    // White board setup
    board[7][0] = new Rook(1, true);
    board[7][1] = new Knight(2, true);
    board[7][2] = new Bishop(3, true);
    board[7][3] = new Queen(4, true);
    board[7][4] = new King(5, true);
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
    board[0][4] = new King(21, false);
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
    
    
    whiteKing = board[7][4];
    blackKing = board[0][4];
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(boolean whiteMove) {
    ArrayList<ChessPiece[][]> possibleBoards = new ArrayList<ChessPiece[][]>();
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        if (board[r][c] != null && board[r][c].isWhite == whiteMove) {
          ArrayList<ChessPiece[][]> moves = board[r][c].getPossibleMoves(this);
          if (moves != null) {
            possibleBoards.addAll(moves);
          } 
        }
      }
    }
    
    ArrayList<ChessPiece[][]> legalBoards = new ArrayList<ChessPiece[][]>();
    for (ChessPiece[][] cb : possibleBoards) {
      // check for if the move puts our own King in check and filter out illegal moves
      
      Pair kingLocation = getLocationForPieceInBoard(cb, whiteMove ? whiteKing.id : blackKing.id);
      System.out.println("KING LOCATION " + kingLocation.r + ", " + kingLocation.c);

      if (!isInCheck(cb, whiteMove)) {
        legalBoards.add(cb);
      } else {
        System.out.println("Illegal move removed");
      }
    }
    
    System.out.println("possible moves: " + possibleBoards.size());
    System.out.println("legal moves: " + legalBoards.size());
    return legalBoards;
  }
  
  // Returns if the King of the given player is in check
  boolean isInCheck(ChessPiece[][] chessBoard, boolean white) {
    // TODO filter any moves that have the <whiteMove> King in check
    Pair kingLocation = getLocationForPieceInBoard(chessBoard, white ? whiteKing.id : blackKing.id);
    if (kingLocation == null) {
      return true; //TODO filter out king captures instead?
    }
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        boolean enemyPieceInSpace = chessBoard[r][c] != null && chessBoard[r][c].isWhite != white;
        if (enemyPieceInSpace && chessBoard[r][c].threatensSpace(chessBoard, kingLocation)) {
          return true;
        } 
      }
    }
    return false;
  }
  
  public boolean isCurrentBoardInCheck(boolean white) {
    return isInCheck(this.board, white);
  }
  
  void makeRandomMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
    if (possibleBoards.isEmpty()) {
      String player = whiteMove ? "White" : "Black";
      System.out.println(player + " ran out of moves!");
      //TODO stalemate!
      return;
    }
    board = possibleBoards.get((int) random(possibleBoards.size()));
  }
  
  void makeMinimaxMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
    // TODO
  }
  
  void makeMCTSMove(boolean whiteMove, ArrayList<ChessPiece[][]> possibleBoards) {
    // TODO
  }
  
  public Pair getLocationForPieceCurrentBoard(int id) {
    return getLocationForPieceInBoard(this.board, id);
  }
  
  int evalBoard() {
    int boardScore = 0;
    // TODO
    return boardScore;
  }
  
  void draw() {
    drawBoard();
    // TODO color squares of valid moves for player?
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        if (board[r][c] != null) {
          board[r][c].draw(r, c);
        }
      }
    }
  }
  
  void drawBoard() {
    for (int r = 0; r < BOARD_WIDTH; r++) {
      for (int c = 0; c < BOARD_WIDTH; c++) {
        noStroke();
        if (r % 2 == c % 2) {
          fill(LIGHT_SQUARE);
        } else {
          fill(DARK_SQUARE);
        }
        rect(c * GRID_SIZE, r * GRID_SIZE, GRID_SIZE, GRID_SIZE);
      }
    }
  }
}

// MARK: Chess pieces

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
  abstract ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard);
  
  // Returns if this piece can capture a piece on the given space if allowed to move again
  abstract boolean threatensSpace(ChessPiece[][] board, Pair space);
  
  int getPoints() {
    return pointValue; 
  }
  
  void draw(int r, int c) {
    image(img, c * GRID_SIZE, r * GRID_SIZE, GRID_SIZE, GRID_SIZE);
  }
}

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
    ChessPiece[][] boardWithoutPiece = copyBoard(currentBoard.board);
    boardWithoutPiece[r][c] = null;
    
    // If space in front of pawn is open, allow moving forward
    if (boardWithoutPiece[movingRow][c] == null) {
      // Moving into a sqaure that doesn't promote
      if (movingRow != promotionRow) {
        ChessPiece[][] move = copyBoard(boardWithoutPiece);
        move[movingRow][c] = this;
        possibleMoves.add(move);
      } else {
        // Move forward into a promotion
        ChessPiece[][] rookPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] knightPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] bishopPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] queenPromotion = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] twoSpaceMove = copyBoard(boardWithoutPiece);
      twoSpaceMove[twoSpaceMoveRow][c] = this;
    }
      
    // Left capture
    if (c-1 >= 0 && boardWithoutPiece[movingRow][c-1] != null && boardWithoutPiece[movingRow][c-1].isWhite != this.isWhite) {
      if (movingRow != promotionRow) {
        ChessPiece[][] leftCapture = copyBoard(boardWithoutPiece);
        leftCapture[movingRow][c-1] = this;
        possibleMoves.add(leftCapture);
      } else {
        // Captures AND promotion!
        ChessPiece[][] rookPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] knightPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] bishopPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] queenPromotion = copyBoard(boardWithoutPiece);
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
        ChessPiece[][] rightCapture = copyBoard(boardWithoutPiece);
        rightCapture[movingRow][c+1] = this;
        possibleMoves.add(rightCapture);
      } else {
        // Captures AND promotion!
        ChessPiece[][] rookPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] knightPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] bishopPromotion = copyBoard(boardWithoutPiece);
        ChessPiece[][] queenPromotion = copyBoard(boardWithoutPiece);
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
        System.out.println("Pawn threatens space " + space.r + "," + space.c);
        return true;
      }
    } else {
      if(space.r == mySpace.r + 1 && Math.abs(mySpace.c - space.c) == 1) {
        System.out.println("Pawn threatens space " + space.r + "," + space.c);
        return true;
      }
    }
    return false;
  }
}

class Rook extends ChessPiece {
  Rook(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_rook" : "black_rook");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = copyBoard(currentBoard.board);
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
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveDown = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveLeft = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveRight = copyBoard(boardWithoutPiece);
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
      if(emptyBetweenRow(board, mySpace, space)){
        System.out.println("Rook threatens space " + space.r + "," + space.c);
        return true;
      }
    } 
    else if (mySpace.c == space.c) {
      // check rows in between for emptiness
      if(emptyBetweenColumn(board, mySpace, space)) {
        System.out.println("Rook threatens space " + space.r + "," + space.c);
        return true;
      }
    }
    
    return false;
  }
}

public boolean emptyBetweenColumn(ChessPiece[][] board, Pair spaceA, Pair spaceB) {
  if (spaceA.c != spaceB.c) {
    //System.out.println("emptyBetweenColumn: Column not equal!");
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
} //TODO move

public boolean emptyBetweenRow(ChessPiece[][] board, Pair spaceA, Pair spaceB) {
  if (spaceA.r != spaceB.r) {
    //System.out.println("emptyBetweenRow: Row not equal!");
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
} //TODO move

class Knight extends ChessPiece {
  Knight(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_knight" : "black_knight");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = copyBoard(currentBoard.board);
    boardWithoutPiece[r][c] = null;
    
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
              ChessPiece[][] move = copyBoard(boardWithoutPiece);
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
              System.out.println("Knight threatens space " + newR + "," + newC); 
              return true;
            }
          }
        }
      }
    }
    return false;
  }
}

class Bishop extends ChessPiece {
  Bishop(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_bishop" : "black_bishop");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = copyBoard(currentBoard.board);
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
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
    if(emptyBetweenDiagonal(board, mySpace, space)) {
      System.out.println("Bishop threatens space " + space.r + "," + space.c);
      return true;
    }
    return false;
  }
}

public boolean emptyBetweenDiagonal(ChessPiece[][] board, Pair spaceA, Pair spaceB) {
  if (Math.abs(spaceA.r - spaceB.r) != Math.abs(spaceA.c - spaceB.c)) {
      //System.out.println("emptyBetweenDiagonal: Not a straight line diagonal!");
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
} //TODO move

class Queen extends ChessPiece {
  Queen(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_queen" : "black_queen");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = copyBoard(currentBoard.board);
    boardWithoutPiece[r][c] = null;
    
    // Check moving like a rook
    int rUp = r-1;
    while (rUp >= 0) {
      ChessPiece pieceInSpace = boardWithoutPiece[rUp][c];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveDown = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveLeft = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveRight = copyBoard(boardWithoutPiece);
      moveRight[r][cRight] = this;
      possibleMoves.add(moveRight);
      
      // If we captured an enemy, stop
      if (pieceInSpace != null) {
        break;
      }
      // Else get next space
      cRight += 1;
    }
    
    // Check bishop moves
    // while loop to check up-left, up-right, down-left, down-right
    rUp = r-1;
    cLeft = c-1;
    while (rUp >= 0 && cLeft >= 0) {
      ChessPiece pieceInSpace = boardWithoutPiece[rUp][cLeft];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
    cRight = c+1;
    while (rUp >= 0 && cRight < BOARD_WIDTH) {
      ChessPiece pieceInSpace = boardWithoutPiece[rUp][cRight];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
    
    rDown = r+1;
    cLeft = c-1;
    while (rDown < BOARD_WIDTH && cLeft >= 0) {
      ChessPiece pieceInSpace = boardWithoutPiece[rDown][cLeft];
      // If ally in space, stop
      if (pieceInSpace != null && pieceInSpace.isWhite == this.isWhite) {
        break;
      } 
      
      // Else can move to that space
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
      ChessPiece[][] moveUp = copyBoard(boardWithoutPiece);
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
    
    if (mySpace.r == space.r) {
      // check columns in between for emptiness
      if(emptyBetweenRow(board, mySpace, space)) {
        System.out.println("Queen threatens space " + space.r + "," + space.c);
        return true;
      }
    } 
    else if (mySpace.c == space.c) {
      // check rows in between for emptiness
      System.out.println("Queen threatens space " + space.r + "," + space.c);
      if(emptyBetweenColumn(board, mySpace, space)) {
        System.out.println("Queen threatens space " + space.r + "," + space.c);
        return true;
      }
    }
    else {
      System.out.println("Queen threatens space " + space.r + "," + space.c);
      if (emptyBetweenDiagonal(board, mySpace, space)) {
        System.out.println("Queen threatens space " + space.r + "," + space.c);
        return true;
      }
    }
    return false;
  }
}

class King extends ChessPiece {
  King(int id, boolean isWhite) {
    super(id, isWhite, 1, isWhite ? "white_king" : "black_king");
  }
  
  ArrayList<ChessPiece[][]> getPossibleMoves(ChessBoard currentBoard) {
    ArrayList<ChessPiece[][]> possibleMoves = new ArrayList<ChessPiece[][]>();
    Pair currentLocation = currentBoard.getLocationForPieceCurrentBoard(this.id);
    int r = currentLocation.r;
    int c = currentLocation.c;
    ChessPiece[][] boardWithoutPiece = copyBoard(currentBoard.board);
    boardWithoutPiece[r][c] = null;
    
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        if (x == 0 && y == 0) {
          continue;
        }
        int newR = r + x;
        int newC = c + y;
        if (0 <= newR && newR < BOARD_WIDTH
          && 0 <= newC && newC < BOARD_WIDTH
          && (boardWithoutPiece[newR][newC] == null || boardWithoutPiece[newR][newC].isWhite != this.isWhite)) {
          ChessPiece[][] move = copyBoard(boardWithoutPiece);
          move[newR][newC] = this;
          possibleMoves.add(move);
        }
      }
    }
    
    // TODO castling?
    return possibleMoves;
  }
  
  boolean threatensSpace(ChessPiece[][] board, Pair space) {
    Pair mySpace = getLocationForPieceInBoard(board, this.id);
    if (Math.abs(space.r - mySpace.r) <= 1 && Math.abs(space.c - mySpace.c) <= 1) {
      System.out.println("King threatens space " + space.r + "," + space.c);
      return true;
    }
    return false;
  }
}

class Pair {
  int r;
  int c;
  
  Pair(int r, int c) {
    this.r = r;
    this.c = c;
  }
}

ChessPiece[][] copyBoard(ChessPiece[][] board) {
  ChessPiece[][] copy = new ChessPiece[BOARD_WIDTH][BOARD_WIDTH];
  for (int r = 0; r < BOARD_WIDTH; r++) {
    for (int c = 0; c < BOARD_WIDTH; c++) {
      copy[r][c] = board[r][c];
    }
  }
  
  return copy;
}

Pair getLocationForPieceInBoard(ChessPiece[][] board, int id) {
  for (int r = 0; r < BOARD_WIDTH; r++) {
    for (int c = 0; c < BOARD_WIDTH; c++) {
      if (board[r][c] != null && board[r][c].id == id) {
        return new Pair(r, c);
      }
    }
  }
  
  System.out.println("PIECE NOT IN BOARD WITH ID " + id);
  return null;
}
