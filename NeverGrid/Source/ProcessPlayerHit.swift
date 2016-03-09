//
//  ProcessPlayerHit.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that blocks if you hit a player
/// raises the game over event
class ProcessPlayerHit : PlayerEnemyCollisionAction {
    
    override var description:String { return "ProcessPlayerHit" }
    
    override func perform() -> SKAction? {
        
        let playerHit = hasPlayerCollidedWithEnemy(world.mainPlayer, enemy: entity)
        if playerHit {
            world.eventBus.raise(GameEvent.GameOver, data: GameOverReason(.EnemyHitPlayer))
            isBlocking = true
        }
        
        return nil
    }
}