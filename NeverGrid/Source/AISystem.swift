//
//  EnemySystem.swift
//  gettingthere
//
//  Created by Benzi on 23/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


class AISystem : System {
    
    var aiController:ParallelActionController
    private var playerLocation:LocationComponent!
    private var playerZone:UInt!
    private var enemyControllerCache = [Int:EnemyController]()
    
    override init(_ world:WorldMapper) {
        self.aiController = ParallelActionController(world: world)

        super.init(world)
        
        aiController.name = "AIController"
        aiController.completionHandler = Callback(self, AISystem.onAICompleted)
        
        world.eventBus.subscribe(GameEvent.PlayerMoveCompleted, handler: self)
        //world.eventBus.subscribe(GameEvent.GameOver, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyDeath, handler: self)
        world.eventBus.subscribe(GameEvent.ClonerDeath, handler: self)
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        case GameEvent.PlayerMoveCompleted: runEnemyControllers()
        //case GameEvent.GameOver: world.eventBus.unsubscribe(self)
        case GameEvent.ClonerDeath: fallthrough
        case GameEvent.EnemyDeath: onEnemyDeath(data as! Entity)
        default: break
        }
    }
    
    override func update(dt: Double) {
        if !aiController.needsToRun { return }
        aiController.update()
    }
    
    func getFramesToSkip(enemyCount:Int) -> Int {
        if enemyCount <= 3 { return 1 }
        if enemyCount <= 5 { return 3 }
        return 5
    }
    
    func runEnemyControllers() {
        
        var enemies = world.enemy.entities()
        if enemies.count == 0 {
            world.eventBus.raise(GameEvent.AICompleted, data: nil)
            return
        }
        
        playerLocation = self.world.location.get(world.mainPlayer)
        playerZone = self.world.level.cells.get(playerLocation)!.zone
        
        // filter enemies only in the current zone in standalone mode
        if world.level.zoneBehaviour == ZoneBehaviour.Standalone {
            enemies = enemies.filter(filterByWarpZone)
        }
        
        
        // filter by enabled enemies
        // that do not need to skip turns
        enemies = enemies.filter(filterByActiveEnemiesThatDoesntNeedToSkipMoves)
        
        
        
        if enemies.count == 0 {
            world.eventBus.raise(GameEvent.AICompleted, data: nil)
            return
        }

        
        // find and sort by closest enemies
        // why sort?, well the controller system
        // is async at the moment, so we try to give all
        // enemies a (slightly) fair chance to make a move
        // by updating the enemies closest to the player first
        // since all enemies try to move in closer to the player
        // if not, we may have a deadlock
        // e,e,e,e,p -> 1 step to right
        // e,e,e, ,e,p -> others not updated
        //  ,e,e,e,e,p -> all updated if we go with closest route
        // note that this does not guarantee that enemies will
        // be moved correctly
        // the core problem is of shared state in async mode, and an enemy
        // cannot idependently make a move without knowing the
        // position of all other enemies
        // if we sequentially run the enemy controller, again by closest to player
        // we can guarantee replayable enemy move behaviour
        // for now, this is not important.
        let enemiesClosestToPlayer = enemies.sort(distanceToPlayerSortComparator)

        
        
        aiController.reset()
        enemyControllerCache.removeAll(keepCapacity: true)

        for (index, enemy) in enemiesClosestToPlayer.enumerate() {
            let (type,controller) = createEnemyController(enemy, index:index)
            aiController.add(controller)
            enemyControllerCache[enemy.id] = controller
        }
        

        // we do not wish to run all enemy controllers at the same
        // time, so split this task up in a couple of update calls
        aiController.needsToRun = true
    }
    
    func onEnemyDeath(enemy:Entity) {
        enemyControllerCache[enemy.id]?.stop()
    }
    
    
    func onAICompleted() {
        world.eventBus.raise(GameEvent.AICompleted, data: nil)
    }
    
    // creates an enemy controller based on enemy type
    func createEnemyController(enemy:Entity, index:Int) -> (EnemyType,EnemyController) {
        let type = world.enemy.get(enemy).enemyType
        var enemyController:EnemyController!
        switch type {
            
        case .SliderLeftRight: fallthrough
        case .SliderUpDown:
            enemyController = SliderEnemyController(entity: enemy, world: world)
        case .Monster:
            enemyController = MonsterEnemyController(entity: enemy, world: world)
        case .OneStep:
            enemyController = BasicEnemyController(entity: enemy, world: world)
        case .TwoStep:
            enemyController = TwoStepEnemyController(entity: enemy, world: world)
        case .Cloner:
            enemyController = CloneableEnemyController(entity: enemy, world: world)
        case .Destroyer:
            enemyController = DestroyerEnemyController(entity: enemy, world: world)
        case .Robot:
            enemyController = RobotController(entity: enemy, world: world)
        default:
            break

        }
        enemyController.name = "\(enemyController.name)_#\(index)"
        return (type,enemyController)
    }
}


extension AISystem {
    
    func filterByWarpZone(e:Entity) -> Bool {
        let enemyLocation = world.location.get(e)
        let enemyZone = world.level.cells.get(enemyLocation)!.zone
        return enemyZone == playerZone
    }
    
    func filterByActiveEnemiesThatDoesntNeedToSkipMoves(e:Entity) -> Bool {
        let enemy = world.enemy.get(e)
        if enemy.enabled {
            if enemy.skipTurns > 0 {
                enemy.skipTurns--
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    func distanceToPlayerSortComparator(enemyA:Entity, enemyB:Entity) -> Bool {
        let enemyLocationA = world.location.get(enemyA)
        let enemyLocationB = world.location.get(enemyB)
        let distanceA = distance(playerLocation, b: enemyLocationA)
        let distanceB = distance(playerLocation, b: enemyLocationB)
        return distanceA <= distanceB
    }
    
    func enemyTypeSorter(e1:Entity, e2:Entity) -> Bool {
        let enemy1 = world.enemy.get(e1)
        let enemy2 = world.enemy.get(e2)
        
        if enemy1.enemyType == EnemyType.Destroyer { return true }
        if enemy2.enemyType == EnemyType.Destroyer { return false }
        
        return true
    }
}

