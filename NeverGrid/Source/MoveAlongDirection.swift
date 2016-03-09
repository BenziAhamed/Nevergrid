//
//  MoveAlongDirection.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that moves an entity along a direction, blocks if move cannot be made
class MoveAlongDirection : EntityAction {
    
    override var description:String { return "MoveAlongDirection" }
    
    var direction:UInt!
    var moveDuration:CGFloat = 0.2
    
    init(entity: Entity, world: WorldMapper, direction:UInt, duration:CGFloat=0.2) {
        super.init(entity: entity, world: world)
        self.direction = direction
        self.moveDuration = duration
    }
    
    override func perform() -> SKAction? {
        
        let location = world.location.get(entity)
        let gridCell = world.level.cells.get(location)!
        let player = world.player.get(entity)
        player.teleportedInLastMove = false
        
        var returnAction:SKAction? = nil
        if direction != Direction.None {
            if world.level.movePossible(gridCell, direction: direction) {
                if let neighbour = world.level.getNeighbour(gridCell, direction: direction) {
                    // update player location
                    location.row = neighbour.location.row
                    location.column = neighbour.location.column
                    
                    world.playerLocation = location
                    
                    
                    // if we are able to move add these steps
                    controller?.insert([
                        ProcessEnemyHit(entity: world.mainPlayer, world: world),
                        DestroyCells(cellFilter:[CellType.Falling], entity: world.mainPlayer, world: world),
                        CollectItems(entity: world.mainPlayer, world: world),
                        Teleport(entity: world.mainPlayer, world: world)
                        ])
                    
                    
                    returnAction = SKAction.moveTo(world.gs.getEntityPosition(neighbour.location), duration: NSTimeInterval(moveDuration))
                }
            } else {
                // we can't move in this direction
                location.stayInPlace()
                shouldWaitForActionCompletion = false
                returnAction = ActionFactory.sharedInstance.getShakeForDirection(direction)
                
                // lets show a bounce alert
                let bounceAlert = entitySprite("bounce_alert_\(Direction.Name[direction]!)")
                bounceAlert.size = world.gs.getSize(FactoredSizes.ScalingFactor.Player)
                bounceAlert.position = world.gs.getEntityPosition(location)
                var targetPosition = CGPointZero
                let offsetAmount:CGFloat = bounceAlert.size.width/2.0
                let offsetAmount_2 = offsetAmount / 2.0
                // offset the position based on direction
                switch direction {
                case Direction.Down:
                    bounceAlert.position = bounceAlert.position.offset(dx: 0.0, dy: -offsetAmount)
                    targetPosition = bounceAlert.position.offset(dx: 0.0, dy: -offsetAmount_2)
                case Direction.Up:
                    bounceAlert.position = bounceAlert.position.offset(dx: 0.0, dy: +offsetAmount)
                    targetPosition = bounceAlert.position.offset(dx: 0.0, dy: +offsetAmount_2)
                case Direction.Left:
                    bounceAlert.position = bounceAlert.position.offset(dx: -offsetAmount, dy: 0.0)
                    targetPosition = bounceAlert.position.offset(dx: -offsetAmount_2, dy: 0.0)
                case Direction.Right:
                    bounceAlert.position = bounceAlert.position.offset(dx: +offsetAmount, dy: 0.0)
                    targetPosition = bounceAlert.position.offset(dx: +offsetAmount_2, dy: 0.0)
                default: break
                }
                bounceAlert.zPosition = EntityFactory.EntityZIndex.Player+1.0
                world.scene!.entitiesNode.addChild(bounceAlert)
                bounceAlert.runAction(
                    (
                        SKAction.moveTo(targetPosition, duration: 0.5)
                        .alongside(SKAction.fadeOutWithDuration(0.5))
                        .alongside(
                            GameSettings().soundEnabled ?
                                ActionFactory.sharedInstance.playNoMove
                            :   SKAction.waitForDuration(0.0)
                        )
                    )
                    .followedBy(SKAction.removeFromParent())
                )
            }
        } else {
            location.stayInPlace()
        }
        
        return returnAction
    }
}
