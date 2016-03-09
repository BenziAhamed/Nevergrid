//
//  PlayerPathGestureRecognizer.swift
//  OnGettingThere
//
//  Created by Benzi on 24/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class PlayerPathGestureRecognizer : UIGestureRecognizer {
    
    var world:WorldMapper
    
    var cellSprites = LocationBasedCache<SpriteComponent>()
    var slideLocations = [LocationComponent]()
    var portalLocations = [LocationComponent]()
    
    var path = [VisitedCell]()
    var lastCell:LocationComponent
    
    
    init(world:WorldMapper, target: AnyObject!, action: Selector) {
        self.world = world
        self.lastCell = LocationComponent(row: -1, column: -1)
        super.init(target: target, action: action)
    }
    
    
    override func reset() {
        super.reset()
        lastCell = LocationComponent(row: -1, column: -1)
        path.removeAll(keepCapacity: true)
        slideLocations.removeAll(keepCapacity: true)
        portalLocations.removeAll(keepCapacity: true)
        cellSprites.clear()
    }
    
    func cacheCellSprites() {
        for cell in world.cell.entities() {
            let l = world.location.get(cell)
            let s = world.sprite.get(cell)
            cellSprites.set(l, item: s)
        }
    }
    
    func findSlideLocations() {
        for p in world.powerup.entities() {
            let powerup = world.powerup.get(p)
            if powerup.powerupType == PowerupType.Slide {
                let location = world.location.get(p)
                slideLocations.append(location)
            }
        }
    }
    
    func findPortalLocations() {
        for p in world.portal.entities() {
                let location = world.location.get(p)
                portalLocations.append(location)
        }
    }
    
    func shouldStop(currentCell:LocationComponent) -> Bool {
        if currentCell == world.location.get(world.mainPlayer) {
            return false // since we already have reached this cell, even if it has a portal
        }
        
        // check if current cell has a slide
        for l in slideLocations {
            if l == currentCell {
                return true
            }
        }
        // check if current cell has a portal
        for l in portalLocations {
            if l == currentCell {
                return true
            }
        }
        return false
    }
    
    func addPathNodes()
    {
        let currentCell = path[path.count-1]
        
        
        // add a node to indicate this is the end node
        currentCell.sprite.node.addChild(createPathNode(currentCell, name: "path"))
        
        // add a node to indicate the direction we came in from
        currentCell.sprite.node.addChild(createPathNode(currentCell, name: "path_\(Direction.Name[Direction.Opposite[ currentCell.direction]!]!)"))
        
        if path.count > 1 {
            let previousCell = path[path.count-2]
            
            // update the previous cell to indicate we moved away from that cell
            previousCell.sprite.node.addChild(createPathNode(previousCell, name: "path_\(Direction.Name[currentCell.direction]!)"))
            if path.count > 2 {
                previousCell.sprite.node.removeChildrenInArray([previousCell.sprite.node.childNodeWithName("path")!])
            }
        }
    }
    
    func createPathNode(cell:VisitedCell, name:String) -> SKSpriteNode {
        let manager = SpriteManager.Shared.grid
        let pathNode = SKSpriteNode(texture: manager.texture("\(name)"))
        pathNode.name = name
        pathNode.size = world.gs.getSize(1.0)
        pathNode.zPosition = EntityFactory.EntityZIndex.GetGridIndex(cell.location.row)
        pathNode.position = CGPointMake(world.gs.sideLength/2, world.gs.sideLength/2)
        pathNode.color = UIColor.lightGrayColor()
        pathNode.colorBlendFactor = 1.0
        return pathNode
    }
    
    func markCellVisited(cell:LocationComponent, direction:UInt, stop:Bool = false)
    {
        lastCell = cell
        let visitedCell = VisitedCell()
        visitedCell.location = lastCell
        visitedCell.direction = direction
        visitedCell.shouldStopPath = shouldStop(cell)
        visitedCell.sprite = cellSprites.get(cell)!
        path.append(visitedCell)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        // if player has slide enabled, we cannot draw a path
        if world.slide.belongsTo(world.mainPlayer) {
            //println("started gesture having slide - failed")
            state = UIGestureRecognizerState.Failed
            return
        }
        
        let location = (touches.first!).locationInNode(world.scene!.worldNode)

        if world.gs.gridFrame.contains(location) {
            
            // check if we started from the cell in which the 
            // player is located
            let playerLocation = world.location.get(world.mainPlayer)
            let currentCell = getLocationComponent(location)
            if !(playerLocation == currentCell) {
                //println("started gesture without touching player - failed")
                state = UIGestureRecognizerState.Failed
                return
            }
            
            cacheCellSprites()
            findSlideLocations()
            findPortalLocations()
            
            markCellVisited(currentCell, direction: Direction.None)
            
            //println("start cell - \(lastCell.description)")
            state = UIGestureRecognizerState.Began
        }
        else {
            //println("started gesture outside grid - failed")
            state = UIGestureRecognizerState.Failed
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        super.touchesMoved(touches, withEvent: event)
        
        
        // if the previous visited cell had a slide don't add further cells
        // if you visit a cell with a slide, the path should terminate
        if path[path.count-1].shouldStopPath { return }
        
        let location = (touches.first!).locationInNode(world.scene!.worldNode)
        if world.gs.gridFrame.contains(location) {
            let currentCell = getLocationComponent(location)
            if !(currentCell == lastCell) {
                
                // we have moved to a new cell
                // can we reach this cell from the last cell?
                let possibleMove = getPossibleMove(lastCell, end: currentCell)
                if world.level.movePossible(lastCell, direction: possibleMove) {
                    //println("moved \(Direction.Name[possibleMove]!) to cell - \(currentCell.description) ")
                    markCellVisited(currentCell, direction: possibleMove)
                    addPathNodes()
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        let location = (touches.first!).locationInNode(world.scene!.worldNode)
        if !world.gs.gridFrame.contains(location) {
            state = UIGestureRecognizerState.Failed
            // remove all nodes
            // since we aborted this path, lets remove all path nodes
            for cell in path {
                for child in cell.sprite.node.children {
                    if child is SKSpriteNode {
                        let c = child as! SKSpriteNode
                        if c.name == nil { continue }
                        if (c.name!).hasPrefix("path") {
                            c.removeFromParent()
                        }
                    }
                }
            }
        }
        
        if path.count > 1 {
            state = UIGestureRecognizerState.Ended
        } else {
            state = UIGestureRecognizerState.Failed
        }
    }
    
    
    func getLocationComponent(location:CGPoint) -> LocationComponent {
        let grid = CGPointMake(world.gs.x, world.gs.y)
        let translated = location.subtract(grid).divide(CGPointMake(world.gs.sideLength+world.gs.cellSpacing, world.gs.sideLength+world.gs.cellSpacing))
        return LocationComponent(row: world.gs.rows-Int(translated.y)-1, column: Int(translated.x))
    }
    
}


class VisitedCell {
    var location:LocationComponent!
    var sprite:SpriteComponent!
    var direction:UInt!
    var shouldStopPath:Bool = false
}