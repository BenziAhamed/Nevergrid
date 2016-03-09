//
//  Systems.swift
//  gettingthere
//
//  Created by Benzi on 21/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


// everything is event based, so this game system holds all
// acts as a bin for all systems 
class GameSystem {

    var systems:[System]
    var world:WorldMapper

    init(_ world:WorldMapper) {
        self.world = world
        self.systems = [System]()
        
        
        // systems are to be added in order of priority
        // state system
        systems.append(StateSystem(world))
        
        // user interaction stuff
        systems.append(InputSystem(world))
        //systems.append(InputFeedbackSystem(world))
        
        // core gameplay mechanics
        systems.append(LevelZoneSystem(world))
        
        systems.append(PlayerSystem(world))
        systems.append(AISystem(world))
        systems.append(PowerupSystem(world))
        systems.append(PhysicsSystem(world))
        
        
        // animations, sounds, camera, action!
        systems.append(AnimationSystem(world))
        
        if GameSettings().soundEnabled {
            systems.append(SoundSystem(world))
        }
        
        systems.append(CameraSystem(world))
        
        systems.append(EmotionSystem(world))
        
        // special effects
        systems.append(CloudSystem(world))
        systems.append(AchievementsSystem(world))
        
        //if world.theme.settings.enableShadows {
        //    systems.append(ShadowSystem(world))
        //}
        
        // entity management
        systems.append(EntityManagerSystem(world))
    }
    
    
    
    func startGame() {
        runGameStartController()
    }
    
    func createEntities() {
        let entityFactory = EntityFactory(world:world)
        entityFactory.setupGame()
    }
    
    
    
    /// animates the player and enemies into the game grid
    /// once they all land, the game started event is fired
    /// for a player, upon landing, the collect items action is also called
    var gameStartController:ParallelActionController!
    func runGameStartController() {
        
        gameStartController = ParallelActionController(world: self.world)
        gameStartController.name = "GameStartController"
        
        for player in world.player.entities() {
            let playerLandingController = EntityActionController(world:self.world)
            playerLandingController.name = "PlayerLandingController"
            
            playerLandingController.add(LandOnLevel(entity: player, world: world))
            playerLandingController.add(RaiseEvent(event: GameEvent.EntityLanded ,entity: player, world: world))
            playerLandingController.add(CollectItems(entity: player, world: world))
            gameStartController.add(playerLandingController)
        }
        for enemy in world.enemy.entities() {
            
            // ignore disabled enemies
            let enemyComponent = world.enemy.get(enemy)
            if !enemyComponent.enabled { continue }
            
            let enemyLandingController = EntityActionController(world:self.world)
            enemyLandingController.name = "\(enemyComponent.enemyType)LandingController"
            
            enemyLandingController.add(LandOnLevel(entity: enemy, world: world))
            enemyLandingController.add(RaiseEvent(event: GameEvent.EntityLanded ,entity: enemy, world: world))
            
            switch enemyComponent.enemyType {
            case .Monster:
                enemyLandingController.add(ShakeWorld(entity: enemy, world: world))
            case .Robot:
                enemyLandingController.add(RobotBootup(entity: enemy, world: world))
            default:
                break
            }
            
            gameStartController.add(enemyLandingController)
        }
        
        gameStartController.completionHandler = Callback(self, GameSystem.raiseGameStarted)
        gameStartController.run()
    }
    
    func raiseGameStarted() {
        self.world.eventBus.raise(GameEvent.GameStarted, data: nil)
    }
    
    func update(dt:Double)
    {
        world.eventBus.update()
        for system in systems {
            system.update(dt)
        }
    }
}
