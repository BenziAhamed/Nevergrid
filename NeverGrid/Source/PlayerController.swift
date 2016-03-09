//
//  PlayerController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerController: EntityActionController {
    
    let moveDirection:UInt
    
    init(world:WorldMapper, moveDirection: UInt) {
        self.moveDirection = moveDirection
        super.init(world: world)
        name = "PlayerController"
        startHandler = Callback(self, PlayerController.onMoveStarted)
        completionHandler = Callback(self, PlayerController.onMoveCompleted)
    }
    func onMoveStarted() {
        world.eventBus.raise(GameEvent.PlayerMoveStarted, data: moveDirection)
    }
    
    func onMoveCompleted() {
        world.eventBus.raise(GameEvent.PlayerMoveCompleted, data: moveDirection)
    }
}