//
//  CheckAlive.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that blocks if you are not alive
class CheckAlive : EntityAction {
    override func perform() -> SKAction? {
        
        // if we no longer exists, we block
        if !world.manager.entityExists(entity) {
            isBlocking = true
            return nil
        }
        
        // if we are not alive, we block
        let e = world.enemy.get(entity)
        isBlocking = !e.alive
        return nil
    }
}