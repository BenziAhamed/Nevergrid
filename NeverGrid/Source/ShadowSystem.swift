//
//  ShadowSystem.swift
//  MrGreen
//
//  Created by Benzi on 28/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class ShadowSystem : System {
    
    var enabled = false
    var shadowCache = LocationBasedCache<SKNode>()
    
    override init(_ world:WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.GameEntitiesCreated, handler: self)
        world.eventBus.subscribe(GameEvent.ZoneKeyCollected, handler: self)
        world.eventBus.subscribe(GameEvent.CellDestroyed, handler: self)
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        case GameEvent.GameEntitiesCreated: fallthrough
        case GameEvent.ZoneKeyCollected:
            computeShadowMap()
            createShadowsForCurrentzoneLevel()
            
        case GameEvent.CellDestroyed:
            removeShadowsIfRequired(data as! Entity)
            computeShadowMap()
            createShadowsForCurrentzoneLevel()


        default: break
        }
    }
    
    func removeShadowsIfRequired(cell:Entity) {
        let location = world.location.get(cell)
        if let sprite = shadowCache.get(location) {
            sprite.removeFromParent()
            shadowCache.clear(location)
        }
    }
    
    func computeShadowMap() {
//        world.level.shadowMap.removeAll(keepCapacity: true)
//        for (index, cell) in enumerate(world.level.walls) {
//            
//            // we are a block or do not belong to the current zone level?
//            if world.level.zoneMap[index] > world.level.zoneLevel || cell == Direction.All {
//                world.level.shadowMap.append(0)
//                continue
//            }
//            
//            
//            let (c,r) = world.level.getWallCR(index)
//            
//            // we have a cell that needs to be checked
//            var hasLeftCell = checkNeighbourExists(column: c, row: r, direction: Direction.Left)
//            var hasRightCell = checkNeighbourExists(column: c, row: r, direction: Direction.Right)
//            var hasBottomCell = checkNeighbourExists(column: c, row: r, direction: Direction.Down)
//            
//            
//            
//            if !hasLeftCell && !hasRightCell && !hasBottomCell {
////                println("cell (\(c),\(r)) = left:\(hasLeftCell)  right:\(hasRightCell)  bottom:\(hasBottomCell) - BOTTOM")
//                world.level.shadowMap.append(47)
//            }
//            else if !hasLeftCell && hasRightCell && !hasBottomCell {
////                println("cell (\(c),\(r)) = left:\(hasLeftCell)  right:\(hasRightCell)  bottom:\(hasBottomCell) - LEFT")
//                world.level.shadowMap.append(45)
//            }
//            else if hasLeftCell && !hasRightCell && !hasBottomCell {
////                println("cell (\(c),\(r)) = left:\(hasLeftCell)  right:\(hasRightCell)  bottom:\(hasBottomCell) - RIGHT")
//                world.level.shadowMap.append(46)
//            }
//            else if hasLeftCell && hasRightCell && !hasBottomCell {
////                println("cell (\(c),\(r)) = left:\(hasLeftCell)  right:\(hasRightCell)  bottom:\(hasBottomCell) - MIDDLE")
//                world.level.shadowMap.append(48)
//            }
//            else {
//                world.level.shadowMap.append(0)
//            }
//        }
        
        
        for c in 0..<world.level.columns {
            for r in 0..<world.level.rows {
                let cell = world.level.cells[c,r]!
                if !cell.canCastShadows {
                    cell.shadows = 0
                } else {
                    let hasLeftCell = hasShadowNeighbour(cell, direction: Direction.Left)
                    let hasRightCell = hasShadowNeighbour(cell, direction: Direction.Right)
                    let hasBottomCell = hasShadowNeighbour(cell, direction: Direction.Down)
                    if !hasLeftCell && !hasRightCell && !hasBottomCell {
                        cell.shadows = 47
                    }
                    else if !hasLeftCell && hasRightCell && !hasBottomCell {
                        cell.shadows = 45
                    }
                    else if hasLeftCell && !hasRightCell && !hasBottomCell {
                        cell.shadows = 46
                    }
                    else if hasLeftCell && hasRightCell && !hasBottomCell {
                        cell.shadows = 48
                    }
                    else {
                        cell.shadows = 0
                    }
                }
            }
        }
        
    }
    
    func hasShadowNeighbour(cell:GridCell, direction:UInt) -> Bool {
        if let neighbour = world.level.getNeighbour(cell, direction: direction) {
            return neighbour.canCastShadows
        }
        return false
    }
    
    func createShadowsForCurrentzoneLevel() {
        for c in 0..<world.level.columns {
            for r in 0..<world.level.rows {

            let cell = world.level.cells[c,r]!
            let cellPosition = world.gs.getCellPosition(row: r, column: c)
            
            var shadowTexture = "destroy"
            switch cell.shadows {
            case 45: shadowTexture = "shadow_left"
            case 46: shadowTexture = "shadow_right"
            case 47: shadowTexture = "shadow_bottom"
            case 48: shadowTexture = "shadow_mid"
            default: break
            }
            
            if shadowTexture == "destroy" {
                if let sprite = shadowCache[c,r] {
                    sprite.removeFromParent()
                    shadowCache[c,r] = nil
                    //println("cell (\(c),\(r)) - DESTROY SHADOW")
                }
            } else {
                
                if let sprite = shadowCache[c,r] {
                    // already created, so just update the sprite texture if texture has changed
                    if let currentTextureName = sprite.getItem("texture") as? String {
                        if currentTextureName != shadowTexture {
                            (sprite as! SKSpriteNode).texture = SpriteManager.Shared.grid.texture(shadowTexture)
                            //println("cell (\(c),\(r)) - UPDATE SHADOW")
                        }
                    }
                }
                else {
                    
                    // creating for the first time
                    let sprite = SKSpriteNode(texture: SpriteManager.Shared.grid.texture(shadowTexture))
                    sprite.size = CGSizeMake(world.gs.sideLength, 1.125*world.gs.sideLength)
                    sprite.position = cellPosition.offset(dx: world.gs.sideLength/2.0, dy: -0.125*world.gs.sideLength)
                    sprite.zPosition = EntityFactory.EntityZIndex.GetGridIndex(-1)
                    sprite.setItem("texture", value: shadowTexture)
                    
                    shadowCache[c,r] = sprite
                    
                    world.scene!.gridNode.addChild(sprite)
                    
                    //println("cell (\(c),\(r)) - ADD SHADOW")
                }
            }
            
        }
        }
        
    }
}
