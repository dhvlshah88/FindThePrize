//
//  ViewController.swift
//  FindThePrize
//
//  Created by Dhaval on 10/17/16.
//  Copyright © 2016 Dhaval. All rights reserved.
//

import UIKit
import GameplayKit

enum ID : Int {
    case none = 0
    case first
    case second
    case prize
}

class GridViewController: UIViewController {
    
    @IBOutlet weak var gridView : UICollectionView!
    @IBOutlet weak var playerOneView : UIView!
    @IBOutlet weak var playerOneScoreLabel : UILabel!
    @IBOutlet weak var playerTwoView : UIView!
    @IBOutlet weak var playerTwoScoreLabel: UILabel!
    
    fileprivate let gridViewIdentifier = "gridViewIdentifier"
    
    var strategist: GKMinmaxStrategist!
    var grid: Grid!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gridView.delegate = self
        self.gridView.dataSource = self
        
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 1
        strategist.randomSource = nil
        
        resetGrid()
    
        self.playerOneView.layer.cornerRadius = self.playerOneView.bounds.width/2
        self.playerOneView.backgroundColor = grid.currentPlayer.color
        self.playerTwoView.layer.cornerRadius = self.playerTwoView.bounds.width/2
        self.playerTwoView.backgroundColor = grid.currentPlayer.opponent.color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: private functions
    func resetGrid() {
        grid = Grid()
        strategist.gameModel = grid
        
        updateUI()
    }
    
    func updateUI() {
        title = "\(grid.currentPlayer.name)"
        
        if grid.currentPlayer.playerId == ID.first.rawValue {
            startFirstAIMove()
        } else {
            startSecondAIMove()
        }
    }
    
    func makeMove() {
        if let nextPosition = grid.nextEmptyCell(fromRow: grid.currentPosition.0, column: grid.currentPosition.1) {
            grid.move(playerID: ID(rawValue: grid.currentPlayer.playerId)!, toRow: nextPosition.0, column: nextPosition.1)
            changeCellColor(atRow: nextPosition.0, column: nextPosition.1, color: grid.currentPlayer.color)
            continueGame()
        }
    }
    
    func startFirstAIMove() {
        DispatchQueue.global().async {
            let strategistTime = CFAbsoluteTimeGetCurrent()
            let position : (Int, Int) = self.positionForAIMove()!
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.makeAIMove(toRow: position.0, column: position.1)
            })
        }
    }

    func startSecondAIMove() {
        
    }
    
    // function to make AI to move to next cell
    func makeAIMove(toRow row: Int, column: Int) {
        if let emptyPosition = grid.nextEmptyCell(fromRow: row, column: column) {
            grid.move(playerID: ID(rawValue: grid.currentPlayer.playerId)!, toRow: emptyPosition.0, column: emptyPosition.1)
            
            continueGame()
        }
    }
    
    func changeCellColor(atRow row: Int, column: Int, color: UIColor) {
        let cell: UICollectionViewCell = self.gridView.cellForItem(at: NSIndexPath(row: row, section: 0))
        cell.backgroundView?.backgroundColor = color
    }
    
    func continueGame() {
        var gameOverTitle: String? = nil
        
        if grid.isWin(for: grid.currentPlayer) {
            gameOverTitle = "\(grid.currentPlayer.name) Wins!"
        }
        
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default, handler: { [unowned self] (action) in
                self.resetGrid()
            })
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        grid.currentPlayer = grid.currentPlayer.opponent
        updateUI()
    }
    
    func positionForAIMove() -> (Int, Int)? {
        if let aiMove = strategist.bestMove(for: grid.currentPlayer) as? Move {
            return (aiMove.row, aiMove.column)
        }
        
        return nil
    }
}

extension GridViewController : UICollectionViewDelegate {
    
}

extension GridViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Grid.column * Grid.row
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell :UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: gridViewIdentifier, for: indexPath)
        
        cell = UICollectionViewCell(frame: CGRect.zero)
        
        return cell
    }
}

