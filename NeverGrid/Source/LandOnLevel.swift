//
//  LandOnLevel.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that animates an entity arrival on the grid
class LandOnLevel : EntityAction {
    
    override var description:String { return "LandOnLevel" }
    
    override func perform() -> SKAction? {
        let sprite = world.sprite.get(entity)
        let location = world.location.get(entity)
        sprite.rootNode.alpha = 0
        
        var initialPosition:CGPoint!
        var finalPosition:CGPoint!
        
        
        if world.mainPlayer != entity {
            // we are an enemy
            let enemy = world.enemy.get(entity)
            initialPosition = world.gs.getEnemyPosition(location.offsetRow(-1), type: enemy.enemyType)
            finalPosition = world.gs.getEnemyPosition(location, type: enemy.enemyType)
            
            for c in getEnemyBounds(world, enemy: entity, fromLocation: location) {
                world.level.cells.get(c)!.occupiedBy = entity
            }
        } else {
            initialPosition = world.gs.getEntityPosition(location.offsetRow(-1))
            finalPosition = world.gs.getEntityPosition(location)
        }
        
        sprite.rootNode.position = initialPosition.offset(dx: 0, dy: 2.0*unitRandom()*world.gs.sideLength)
        return ActionFactory.sharedInstance.createPopInAction(sprite.rootNode, destination: finalPosition)
        
    }
}