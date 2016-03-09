//
//  PlayerEnemyCollisionAction.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerEnemyCollisionAction : EntityAction {
    
    // TODO: check why we can override desription twice
    //override var description:String { return "PlayerEnemyCollisionAction" }
    
    func hasPlayerCollidedWithEnemy(player:Entity, enemy:Entity) -> Bool {
        let pLocation = world.playerLocation!
        let eLocation = world.location.get(enemy)
        
        let enemyBounds = getEnemyBounds(world, enemy: enemy, fromLocation: eLocation)
        return enemyBounds.contains(pLocation)
    }
}