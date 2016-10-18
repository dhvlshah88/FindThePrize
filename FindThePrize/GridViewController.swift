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
    
    var firstStrategist: GKMinmaxStrategist!
    var secondStrategist: GKMinmaxStrategist!
    
    var grid: Grid!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gridView.delegate = self
        self.gridView.dataSource = self
        
        firstStrategist = GKMinmaxStrategist()
        firstStrategist.maxLookAheadDepth = 1
        firstStrategist.randomSource = nil
        
        secondStrategist = GKMinmaxStrategist()
        secondStrategist.maxLookAheadDepth = 1
        secondStrategist.randomSource = nil
        
        resetGrid()
    
        self.playerOneView.layer.cornerRadius = 60/2
        self.playerOneView.backgroundColor = grid.currentPlayer.color
        self.playerOneScoreLabel.textColor = grid.currentPlayer.color
        self.playerTwoView.layer.cornerRadius = 60/2
        self.playerTwoView.backgroundColor = grid.currentPlayer.opponent.color
        self.playerTwoScoreLabel.textColor = grid.currentPlayer.opponent.color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: private functions
    func resetGrid() {
        grid = Grid()
        firstStrategist.gameModel = grid
        secondStrategist.gameModel = grid
        
        updateUI()
        
        self.gridView.reloadData()
    }
    
    func updateUI() {
        title = "\(grid.currentPlayer.name)"
        self.gridView.reloadData()
        
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
            let position : (Int, Int) = self.positionForFirstAIMove()!
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.makeAIMove(toRow: position.0, column: position.1)
            })
        }
    }
    
    func startSecondAIMove() {
        DispatchQueue.global().async {
            let strategistTime = CFAbsoluteTimeGetCurrent()
            let position : (Int, Int) = self.positionForSecondAIMove()!
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.makeAIMove(toRow: position.0, column: position.1)
            })
        }
    }

    // function to make AI to move to next cell
    func makeAIMove(toRow row: Int, column: Int) {
        if let emptyPosition = grid.nextEmptyCell(fromRow: row, column: column) {
            grid.move(playerID: ID(rawValue: grid.currentPlayer.playerId)!, toRow: emptyPosition.0, column: emptyPosition.1)
            changeCellColor(atRow: emptyPosition.0, column: emptyPosition.1, color: grid.currentPlayer.color)
            continueGame()
        }
    }
    
    func changeCellColor(atRow row: Int, column: Int, color: UIColor) {
        let cell: UICollectionViewCell = self.gridView.cellForItem(at:NSIndexPath(row: column, section: row) as IndexPath)!
        let view : UIView = UIView(frame: cell.frame)
        view.layer.cornerRadius = cell.frame.height/2
        view.backgroundColor = color
        cell.backgroundView = view
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
    
    func positionForFirstAIMove() -> (Int, Int)? {
        if let aiMove = firstStrategist.bestMove(for: grid.currentPlayer) as? Move {
            return (aiMove.row, aiMove.column)
        }
        
        return nil
    }
    
    func positionForSecondAIMove() -> (Int, Int)? {
        if let aiMove = secondStrategist.bestMove(for: grid.currentPlayer) as? Move {
            return (aiMove.row, aiMove.column)
        }
        
        return nil
    }
}

extension GridViewController : UICollectionViewDelegate {
    
}

extension GridViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Grid.column
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Grid.row
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell :UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: gridViewIdentifier, for: indexPath)
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        if cell.backgroundView == nil {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundView?.backgroundColor?.withAlphaComponent(0.7)
        }
        return cell
    }
}

