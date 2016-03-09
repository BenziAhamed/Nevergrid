//
//  DefaultPlayerController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


class DefaultPlayerController: PlayerController {
    
    override init(world: WorldMapper, moveDirection: UInt) {
        super.init(world: world, moveDirection: moveDirection)
        super.name = "DefaultPlayerController"
        add(MoveAlongDirection(entity: world.mainPlayer, world: world, direction: moveDirection))
        add(CheckGameWon(entity: world.mainPlayer, world: world))
    }
}
