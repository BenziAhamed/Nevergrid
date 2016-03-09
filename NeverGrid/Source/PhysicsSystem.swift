//
//  PhysicsSystem.swift
//  OnGettingThere
//
//  Created by Benzi on 07/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class PhysicsSystem : System, SKPhysicsContactDelegate {
    
    struct EntityCategory {
        static let Player:UInt32        = 0x1 << 0
        static let Enemy:UInt32         = 0x1 << 1
    }
    
    override init(_ world:WorldMapper) {
        super.init(world)
        
        world.eventBus.subscribe(GameEvent.SceneLoaded, handler: self)
        world.eventBus.subscribe(GameEvent.EntityLanded, handler: self)
        world.eventBus.subscribe(GameEvent.CloneCreated, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyMadeVisibleForZone, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyDeath, handler: self)
        world.eventBus.subscribe(GameEvent.ClonerDeath, handler: self)
    }
    
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch(event) {
        case GameEvent.SceneLoaded:
            setupScene()
            
            // attach physics bodies initially only when
            // we have landed on the grid
        case GameEvent.EntityLanded:
            if world.mainPlayer.id == (data as! Entity).id {
                attach(data as! Entity, category:EntityCategory.Player, contacts:EntityCategory.Enemy, collisions:EntityCategory.Enemy)
            } else {
                attach(data as! Entity, category:EntityCategory.Enemy, contacts:EntityCategory.Player, collisions:EntityCategory.Player)
            }
            
            
            // when a clone is created and finally entered, make sure we
            // can attach a body
        case GameEvent.CloneCreated: fallthrough
        case GameEvent.EnemyMadeVisibleForZone:
            attach(data as! Entity, category:EntityCategory.Enemy, contacts:EntityCategory.Player, collisions:EntityCategory.Player)

        case GameEvent.ClonerDeath: fallthrough
        case GameEvent.EnemyDeath:
            detach(data as! Entity)
            
        default: break
        }
    }
    
    /// sets up the contact delegate of the scene to self
    func setupScene() {
        world.scene!.physicsWorld.contactDelegate = self
    }
    
    
    /// attaches a physics body to the entity
    func attach(entity:Entity, category:UInt32, contacts:UInt32, collisions:UInt32) {
        let sprite = world.sprite.get(entity)
        
//        println("sprite.node.size = \(sprite.node.size)")
//        println("sprite.node.size = \(sprite.node.size.scale(0.8))")
        
        sprite.node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.node.size.scale(0.8))
        
        // not dynamic initially, and not affected by gravity
        sprite.node.physicsBody!.dynamic = true
        sprite.node.physicsBody!.affectedByGravity = false
        
        sprite.node.physicsBody!.categoryBitMask = category
        sprite.node.physicsBody!.contactTestBitMask = contacts
        sprite.node.physicsBody!.collisionBitMask = collisions
        sprite.node.physicsBody!.usesPreciseCollisionDetection = false
        
        sprite.node.setItem("entity", value: entity)
        
        sprite.node.physicsBody!.linearDamping = 0.0
        sprite.node.physicsBody!.angularDamping = 0.9
        
        sprite.node.physicsBody!.allowsRotation = false
    }

    
    /// removes the physics body associated with the entity
    func detach(entity:Entity) {
        
        // if we are not frozen
        if !world.freeze.belongsTo(entity) {
            let sprite = world.sprite.get(entity)
            sprite.node.physicsBody = nil
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {

        // find which is the player and which is the enemy
        var player:SKPhysicsBody!
        var enemy:SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask == EntityCategory.Player {
            player = contact.bodyA
            enemy = contact.bodyB
        } else {
            player = contact.bodyB
            enemy = contact.bodyA
        }
        
        let playerEntity = player.node!.getItem("entity") as! Entity
        let enemyEntity = enemy.node!.getItem("entity") as! Entity
        
        // if we hit an enemy when then enemy is frozen
        // throw the enemy away
        if world.freeze.belongsTo(enemyEntity) {

            var thrust:CGFloat = world.gs.sideLength * FactoredSizes.PhysicsSystem.thrustFactor
            var angularImpulse:CGFloat = 0.0
            var incidence = CGPointZero
            
            // calculate the thrust direction
            // identify the direction in which the player
            // is coming to hit the enemy
            // and calculate the angular vector based on that
            let playerLocation = world.location.get(playerEntity)
            let previousLocation = LocationComponent(row: playerLocation.previousRow, column: playerLocation.previousColumn)
            let move = getPossibleMove(previousLocation, end: playerLocation)
            
            switch move {
            case Direction.Right:
                incidence = CGPointMake(5, 7)
                angularImpulse = -0.01
            case Direction.Left:
                incidence = CGPointMake(-5, 7)
                angularImpulse = 0.01
            case Direction.Up:
                incidence = CGPointMake(0, 10)
            case Direction.Down:
                incidence = CGPointMake(0, -10)
            default:break
            }
            
            let incidenceAngle = player.node!.position.add(incidence).angleTo(player.node!.position)
            let thrustVector = CGVectorMake(thrust * CGFloat(cos(Float(incidenceAngle))), thrust * CGFloat(sin(Float(incidenceAngle))) )
            
            // so that we do not hit players further
            enemy.categoryBitMask = 0
            enemy.contactTestBitMask = 0
            enemy.collisionBitMask = 0
            
            // so that we fall slightly
            enemy.affectedByGravity = true
            enemy.allowsRotation = true

            // fling away from the player, rotating slightly
            enemy.applyImpulse(thrustVector)
            enemy.applyAngularImpulse(angularImpulse)
            
            // correct the Zindex so that we appear on top of everything
            let sprite = world.sprite.get(enemyEntity)
            sprite.node.zPosition = EntityFactory.EntityZIndex.Top
        } else {
            
            // at this stage its going to be game over
            // so update the collision category of all enemies
            // that will allow them to collide with one another
            for e in world.enemy.entities() {
                let sprite = world.sprite.get(e)
                let physicsBody = sprite.node.physicsBody!
                physicsBody.collisionBitMask = EntityCategory.Player | EntityCategory.Enemy
            }
            
        }
        
    }
}