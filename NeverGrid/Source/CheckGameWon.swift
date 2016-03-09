//
//  CheckGameWon.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that blocks the game is won, ie no more
/// goals are left to collect
class CheckGameWon : EntityAction {
    
    override var description:String { return "CheckGameWon" }
    
    override func perform() -> SKAction? {
        
        
        // update state of each condition
        for condition in world.conditions {
            condition.update(world)
        }
        
        var won = true
        var lost = false
        
        for condition in world.conditions {
            // to win all winning conditions must be satisfied
            if condition.role == GameConditionRole.Win {  won = won && (condition.met) }
            
            // to lose, any one losing condition can be met
            if condition.role == GameConditionRole.Lose { lost = lost || (condition.met) }
        }
        
        
        // TODO: for now we win only if we collect all coins
        // or lose if we ran out of moves
        
        if won {
            world.eventBus.raise(GameEvent.GameOver, data: GameOverReason(.AllCoinsCollected))
            self.isBlocking = true
        }
            
        else if lost {
            world.eventBus.raise(GameEvent.GameOver, data: GameOverReason(.RanOutOfMoves))
            self.isBlocking = true
        }
        
        return nil
    }
}
