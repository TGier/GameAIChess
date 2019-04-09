The images have been taken from various stages in the AI development, with the majority being taken from a recently played game.
Please find an explanation for each image below:

In all cases, the WHITE player is using the MINIMAX AI and the BLACK player is using our MCTS AI. For square notation, assume columns are letters right to left (A-H) and rows are numbers from bottom to top(1-8)
The most recently played move has the start and end squares highlighted in yellow

1) InfiniteLoop_annotated:
The players alternated moving their pieces back and forth on the given arrows to move BLACK in and out of check.
Ultimately the loop was broken as the BLACK player explored a different branch during its MCTS. This was the first game where we put the two AI against each other.

2) Black_Ignored_Free_Piece:
In this example, BLACK had the option to capture the WHITE knight with its king at (E,7), but instead advances a pawn from from (E,5) -> (E,4). WHITE was then able to move the knight to safety from (D,6) -> (C,8) also putting the BLACK king in check.
This is an example of MCTS choosing a suboptimal move as it may not have really explored the consequences of this capture. The move chosen instead is marked in the annotated version of this image.

3) Opening_Move_WhiteMINIMAX_BlackMCTS:
This is an example opening by the AI. The moves they make are often very random, though the WHITE player opens up their board a lot more and will sometimes even attempt to move into the Queen's gambit.
Neither AI has any notion of an opening book, so moves here are based off of almost no information.

4) White_Corners_Black
WHITE was relatively consistently able to corner the MCTS BLACK AI. It would often setup long distance threats, such as the Queen at (G,8) and the Bishop at (H,3). The WHITE MINIMAX AI seems to work a lot more on piece capture.
This makes sense as the MINIMAX algorithm uses a point evaluation system for pieces (summing piece values for the board) where capturing may be preferable to more sophisticated positioning.

5) White_Wins:
WHITE cornered the BLACK king and moved in with the Queen (typically frowned apon by the MINIMAX algorithm as Queens are given high values) and forces BLACK into a checkmate.
The MINIMAX AI is typically very good at closing out a game, especially when only a few moves from checkmate.




General issues and observations:
1) Our MCTS doesn't save data between steps, meaning every move is training from scratch and throwing out a lot of playouts. We want to preserve this data before the final turn in, as ideally more training data makes MCTS better.
2) Lack of opening move books means our AI players both make very random seeming moves from the start. MINIMAX can only see 5 moves ahead (for playability with regards to time) and thus sees a lot of boards with the same values.
3) Increased complexity to the board state such as tracking the 3-fold repitition for stalemates may help both AI, especially MCTS, with evaluating playouts faster as games couldn't just be the same moves over and over.
4) Our exploration-exploitation values in MCTS need to be better tuned. We need to experiment more with the selection formula that accounts for exploiting good nodes while also allowing for more exploration.
5) MCTS does not evaulate the state of the board past "is the game over?" Thus we saw a lot of moves by the BLACK AI that were just bad. They would ignore free pieces, or make suboptimal moves as it didn't have the capacity to really figure out that "capturing X piece gives me more chances to win" without relying on random exploration. This is definitely a consequence of our computing limitations and the fact we stop our MCTS training after 10 seconds to make the game playable.
6) At low learning times/with small sets of training data, MCTS doesn't really perform much differently than a random AI. We hope to fix this with our plan for observation 1.