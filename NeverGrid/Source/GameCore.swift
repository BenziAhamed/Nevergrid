//
//  GameCore.swift
//  MrGreen
//
//  Created by Benzi on 14/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation



/// returns the bounds of an enemy
func getEnemyBounds(world:WorldMapper, enemy:Entity, fromLocation:LocationComponent) -> [LocationComponent] {
    let enemyType = world.enemy.get(enemy).enemyType
    
    if enemyType == EnemyType.Monster {
        return [
            fromLocation,
            fromLocation.neighbourTop,
            fromLocation.neighbourRight,
            fromLocation.neighbourTopRight
        ]
    }
    else {
        return [fromLocation]
    }
}


enum GameOverReasonType {
    case AllCoinsCollected
    case RanOutOfMoves
    case PlayerHitEnemy
    case PlayerCrashedIntoEnemy
    case EnemyHitPlayer
    case PlayerStuck
    case PlayerCornered
}

class GameOverReason {
    let state:GameOverReasonType
    init(_ state:GameOverReasonType) {
        self.state = state
    }
    var won:Bool {
        return state == GameOverReasonType.AllCoinsCollected
    }
}