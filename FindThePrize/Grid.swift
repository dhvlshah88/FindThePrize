//
//  Grid.swift
//  FindThePrize
//
//  Created by Dhaval on 10/17/16.
//  Copyright © 2016 Dhaval. All rights reserved.
//

import UIKit
import GameplayKit

class Grid: NSObject, GKGameModel {
    
    static let row = 5
    static let column = 5
    let corners : [(Int, Int)] = [(0, 0), (0, Grid.column - 1), (Grid.row - 1, 0), (Grid.row * Grid.column - 1, Grid.row * Grid.column - 1)];
    let possibleCells = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    
    var currentPlayer: Player
    var currentPosition: (Int, Int) = (-1, -1)
    var positionMap: [Int: [(Int, Int)]]
    
    var prizePosition : (Int, Int)
    var cells = [ID]();
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
   
    var players : [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    override init() {
        for _ in 0 ..< Grid.row * Grid.column {
            cells.append(.none)
        }
        
        self.currentPlayer = Player.allPlayers[0]
  
        positionMap = [Int: [(Int, Int)]]()
        for player in Player.allPlayers {
            var indexes = [(Int, Int)]()
            if positionMap[player.playerId] == nil {
                var temp = Grid.randomPlayerIndex(from: corners)
                if currentPosition == (-1,-1) {
                    currentPosition = temp
                    indexes.append(currentPosition)
                } else {
                    while currentPosition == temp {
                        temp = Grid.randomPlayerIndex(from: corners)
                    }
                    indexes.append(temp)
                }
                positionMap[player.playerId] = indexes
            }
        }
        
        prizePosition = Grid.randomPrizeIndex(excluding: corners)
        cells[prizePosition.0 + prizePosition.1 * Grid.column] = .prize
        
        super.init();
    }
    
    func track(position: (Int, Int)) {
        var indexes : [(Int, Int)]
        if positionMap[self.currentPlayer.playerId] != nil {
            indexes = positionMap[self.currentPlayer.playerId]!
            indexes.append(Grid.randomPlayerIndex(from: corners))
//            positionMap[self.currentPlayer.playerId] = indexes
        }
    }
    
    func player(atRow row: Int, column: Int) -> ID {
        return cells[row + column * Grid.column]
    }
    
    func set(playerID: ID, in row: Int, column: Int) {
        cells[row + column * Grid.column] = playerID
    }

//    func isCellEmpty(atRow row: Int, column: Int) -> Bool {
//        let id : ID = player(atRow: row, column: column)
//        if id == .none  || id == .prize {
//            return true
//        }
//    
//        return false
//    }
    
    func nextEmptyCell(fromRow row: Int, column: Int) -> (Int, Int)? {
        for cell in possibleCells {
            let id = player(atRow: row + cell.0, column: column + cell.1)
            if id == .none  || id == .prize {
                return (row + cell.0, column + cell.1)
            }
        }
       
        return nil
    }
    
    func canMove(fromRow row: Int, column:Int) -> Bool {
        return nextEmptyCell(fromRow: row, column: column) != nil
    }
    
    func move(playerID: ID, toRow row: Int, column: Int) {
        if let position = nextEmptyCell(fromRow: row, column: column) {
            set(playerID: playerID, in: position.0, column: position.1)
        }
    }
    
    // MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Grid()
        copy.setGameModel(self)
        return copy
    }
    
    // MARK: GKGameModel
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let grid = gameModel as? Grid {
            cells = grid.cells
            currentPlayer = grid.currentPlayer
        }
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let positions = positionMap[player.playerId]
        let lastPosition: (Int, Int) = (positions?.last)!
        
        if lastPosition == prizePosition {
            return true
        }
        
        return false
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        if let playerObj = player as? Player {
            
            if isWin(for: playerObj) || isWin(for: playerObj.opponent) {
                return nil
            }
            
            var moves = [Move]()
            
            for cell in possibleCells {
                if canMove(fromRow: cell.0, column: cell.1) {
                    moves.append(Move(row: cell.0, column: cell.1))
                }
            }
            
            return moves
        }
        
        return nil
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            set(playerID: ID(rawValue: currentPlayer.playerId)!, in: move.row, column: move.column)
            self.track(position: (move.row, move.column))
            currentPlayer = currentPlayer.opponent
        }
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObj = player as? Player {
            if isWin(for: playerObj) {
                playerObj.score += 5
                return playerObj.score
            } else if isWin(for: playerObj.opponent) {
                playerObj.opponent.score += 5
                return playerObj.opponent.score
            }
        }
        
        return 0
    }
}

extension Grid  {
    
    static func randomPrizeIndex(excluding indexes: [(Int, Int)]) -> (Int, Int) {
        var randomRow: Int, randomCol: Int
        repeat {
            randomRow = Int(arc4random_uniform(UInt32(Grid.row)))
            randomCol = Int(arc4random_uniform(UInt32(Grid.column)))
        } while Grid.contains(indexes, (randomRow, randomCol))
        
        return (randomRow, randomCol)
    }
    
    static func randomPlayerIndex(from indexes: [(Int, Int)]) -> (Int, Int) {
        let randomIndex = Int(arc4random_uniform(UInt32(indexes.count)))
        return indexes[randomIndex]
    }
    
    static func contains(_ a:[(Int, Int)], _ v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
}

