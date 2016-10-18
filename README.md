# FindThePrize - An app that showcases the use of GameKit API.
## The purpose of the app is to play two AI player against each other. Also this app is written entirely in swift.

**Classes to know before running this app**

 * **_Grid_** - This class represent 5 x 5 grid where each player can select and play their move. This class implements GKGameModel protocol.
 * **_Player_** - This class represent the player in the game and contains their characteristic. This class implements GKGameModelPlayer protocol
 * **_Move_** - This class represent the player's move. This class contains position (row, column) on the grid.
 * **_GridViewController_** - This class represent game view. 
 
 
> Note: This solution is still partial as it doesn't conatin backtracking logic and crashes randomly. 
