
## FindThePrize - An app that showcases the use of GameKit API.
######The purpose of the app is to play two AI player against each other. Also this app is written entirely in swift.

** Classes to know before running this app **

 *Grid* - This class represent 5 x 5 grid where each player can select and play their move. This class implements GKGameModel protocol.
 *Player* - This class represent the player in the game and contains their characteristic. This class implements GKGameModelPlayer protocol
 *Move* - This class represent the player's move. This class contains position (row, column) on the grid.
 *GridViewController* - This class represent game view. 
 
 > Note: This solution is still partial as it doesn't conatin backtracking logic and crashes randomly. 
