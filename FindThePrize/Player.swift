//
//  Player.swift
//  FindThePrize
//
//  Created by Dhaval on 10/17/16.
//  Copyright © 2016 Dhaval. All rights reserved.
//

import UIKit
import GameplayKit

class Player: NSObject, GKGameModelPlayer {
    
    let color : UIColor
    var score : Int
    var name : String
    var playerId: Int
    
    static var allPlayers : [Player] {
        return [Player(id: ID.first, name: "Player One", color: UIColor.randomColor()), Player(id: ID.second, name: "Player Two", color: UIColor.randomColor())]
    }
    
    var opponent: Player {
        if playerId == ID.first.rawValue {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
    
    init(id: ID, name: String, color: UIColor) {
        self.playerId = id.rawValue
        self.name = name
        self.color = color
        self.score = 0
        
        super.init()
    }
}
