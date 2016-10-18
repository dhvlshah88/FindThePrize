//
//  Move.swift
//  FindThePrize
//
//  Created by Dhaval on 10/17/16.
//  Copyright © 2016 Dhaval. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {

    var column: Int
    var row: Int
    var value: Int = 0
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
    
}
