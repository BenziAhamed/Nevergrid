//
//  CameraSystem.swift
//  MrGreen
//
//  Created by Benzi on 23/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// The camera system is responsible for zooming and panning game content
/// based on the bounds of the currently playing zone grid
class CameraSystem : System {
    
    var zoneBounds:[ZoneBounds]!
    var unlockedZones = [UInt:Bool]()
    
    override init(_ world:WorldMapper){
        super.init(world)
        world.eventBus.subscribe(GameEvent.GameEntitiesCreated, handler: self)
        world.eventBus.subscribe(GameEvent.ZoneKeyCollected, handler: self)
        
        if world.level.zoneBehaviour == ZoneBehaviour.Standalone {
            world.eventBus.subscribe(GameEvent.PlayerMoveCompleted, handler: self)
        }
    }
        
        
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        
        case GameEvent.GameEntitiesCreated:
            zoneBounds = world.level.calculateZoneBounds()
            for i in 0...world.level.initialZone {
                unlockedZones[UInt(i)] = true
            }
            // when the world is loaded initially, center on the original bounds
            // so that the scale effect appears to happen from the centre of the screen
                // take the center of the original zone zone
                // translate to center of the game frame
            self.world.scene!.cameraNode.position = getActiveZoneBounds().mid().subtract(world.gs.frame.mid())
            centerCameraOnZone()

        case GameEvent.ZoneKeyCollected:
            unlockZone(data as! Entity)
            centerCameraOnZone()
        
        case GameEvent.PlayerMoveCompleted:
            updateCameraIfPlayerZoneChanged()
        
        default: break
        
        }
    }
    
    func unlockZone(zoneKey:Entity) {
        let zone = world.zoneKey.get(zoneKey)
        unlockedZones[zone.zoneID] = true
    }
    
    func getActiveZoneBounds() -> CGRect {
        if world.level.zoneBehaviour == ZoneBehaviour.Standalone {
            // find the current zone the player is in and return the bounds
            // of that zone
            let zone = world.level.cells.get(world.playerLocation)!.zone
            return zoneBounds[Int(zone)].getRectBounds(world.gs)
        } else {
            // merge all unlocked zones and return the combined rect
            var unlockedZoneBounds = zoneBounds[0]
            if zoneBounds.count > 1 {
                for i in 1..<zoneBounds.count {
                    if unlockedZones[UInt(i)] == true {
                        unlockedZoneBounds = unlockedZoneBounds.combine(zoneBounds[i])
                    }
                }
            }
            return unlockedZoneBounds.getRectBounds(world.gs)
        }
    }
    
    func updateCameraIfPlayerZoneChanged() {
        let currentLocation = world.location.get(world.mainPlayer)
        
        if !currentLocation.hasChanged() { return }
        
        let currentZone = world.level.cells.get(currentLocation)!.zone
        let previousZone = world.level.cells.get(currentLocation.previous())!.zone
        
        //println("zone: \(previousZone) -> \(currentZone)")
        
        if currentZone != previousZone {
            centerCameraOnZone()
        }
    }
    
    func centerCameraOnZone() {
        
        // find the bounds of the current zone level zone with respect
        // to the overall game grid
        // try to scale this zone bounds to match the size of the overall
        // game grid, so that a small area of the grid will scale up to show
        // as much as possible on the screen. The camera is adjusted to centre
        // on the scaled portion of the zone zone
        

        // the current bounds of the zone level zone
        let bounds = getActiveZoneBounds()
        
        
        // find out how much coverage is present due to this bounds
        // we try to scale by an amount contributed by the horizonal/vertical
        // side that has the max coverage contribution
        let targetFrame = world.gs.frame.scale(FactoredSizes.CameraSystem.targetFrameSize)
        let coverage = bounds.coverage(forRect: targetFrame)
        
        var scale:CGFloat = 1.0
        
        if coverage > 1.0 {
            scale = 1.0/coverage
        }
        
        
//        println("coverage:\(coverage) scale:\(scale)")
//        println("bounds: \(bounds)")
//        println("world.gs.gridFrame: \(world.gs.gridFrame)")
//        println("world.gs.frame: \(world.gs.frame)")
        
//
//        // original bounds
//        // green
//        let boundsDebug = SKSpriteNode(texture: nil, color: UIColor.greenSea(), size: bounds.size)
//        boundsDebug.anchorPoint = CGPointZero
//        boundsDebug.position = bounds.origin
//        boundsDebug.alpha = 0.5
//        
//        
//        let newboundsDebug = SKSpriteNode(texture: nil, color: UIColor.pomegranate(), size: world.gs.gridFrame.size)
//        newboundsDebug.anchorPoint = CGPointZero
//        newboundsDebug.position = world.gs.gridFrame.origin
//        newboundsDebug.alpha = 0.5
//        
//        
//        world.scene!.debugNode.addChild(boundsDebug)
//        world.scene!.debugNode.addChild(newboundsDebug)
        
        zoomCamera(bounds, scale)
    }
    
    func zoomCamera(previousBounds:CGRect, _ scale:CGFloat) {
        
        // find the new scaled bounds
        let newBounds = previousBounds.scale(scale)
        
        // at this stage, we have the scale amount, and the translated bounds
        // of the zone zone. so we try to scale the world node and centre the camera
        // at the centre of the new bounds area
        let time = 1.0
        let adjustedScreenCenterForTransformedZoneRect = newBounds
            .mid() // take the center of the new zone zone
            .subtract(world.gs.frame.mid()) // translate to center of the game frame
            .multiply(1.0/scale) // adjust with inverse scale to undo the scale operation
        
        
        let scaleAction = SKAction.scaleTo(scale, duration: time)
        let centerOnScreenAction = SKAction.moveTo(adjustedScreenCenterForTransformedZoneRect, duration: time)
        
        scaleAction.timingMode = SKActionTimingMode.EaseOut
        centerOnScreenAction.timingMode = SKActionTimingMode.EaseOut
        
        self.world.scene!.worldNode.runAction(scaleAction)
        self.world.scene!.cameraNode.runAction(centerOnScreenAction)
    }
    
    func centerOnPlayer() {
        let screenCenter =
            world.sprite.get(world.mainPlayer).node.position // take the center of the the player
            .subtract(world.gs.frame.mid()) // translate to center of the game frame
        self.world.scene!.cameraNode.position = screenCenter
    }
}


    