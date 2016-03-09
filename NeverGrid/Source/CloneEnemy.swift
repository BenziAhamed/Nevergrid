//
//  CloneEnemy.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

// action that clones an enemy
// used by the cloner type of enemy
class CloneEnemy : EntityAction {
    
    override var description:String { return "CloneEnemy" }
    
    var moveStrategy:EnemyMoveStrategy!
    
    init(entity: Entity, world: WorldMapper, moveStrategy:EnemyMoveStrategy)  {
        super.init(entity: entity, world: world)
        self.moveStrategy = moveStrategy
    }
    
    override func perform() -> SKAction? {
        
        let parentCloner = world.enemy.get(entity)
        
        // decrement the wait counter
        parentCloner.stepsUntilNextClone--
        
        // ready to clone in next step?
        // start shaking
        if parentCloner.stepsUntilNextClone == 1 {
            world.eventBus.raise(GameEvent.EnemyEnraged, data: entity)
        }
        
        // check if we need to attempt to clone at this turn
        // if so do it
        if parentCloner.stepsUntilNextClone <= 0 {
            let bestMove = moveStrategy.getMove()
            if bestMove.direction != Direction.None {
                // create a clone
                let factory = EntityFactory(world: world)
                let clone = factory.cloneEnemy(entity)
                world.eventBus.raise(GameEvent.CloneCreated, data: clone)
                
                
                // update the clone's location to the target
                let location = world.location.get(clone)
                location.row = bestMove.row
                location.column = bestMove.column
                
//                if bestMove.direction == Direction.Down {
//                    CorrectZIndex(entity: clone, world: world, row: location.row).perform()
//                }
                
                
                
                // create a new controller for the clone
                // and let it run. this is a one off activity
                // in the next turn, the AI system will create
                // the correct controller for this clone
                let cloneController = NewlyClonedEnemyController(entity: clone, world: world)
                cloneController.run()
                
                // now that cloning was possible
                // update the clones counter and reset
                // counters
                // NOTE: cloning will be attempted
                parentCloner.clonesCreated++
                parentCloner.stepsUntilNextClone = EnemyComponent.ClonerSettings.StepsToWaitUntilCloneAction
                
                if parentCloner.clonesCreated == 1 {
                    attachClonerStage()
                }
                
                world.eventBus.raise(GameEvent.EnemyCalmed, data: entity)
            } else {
                // since we have to clone but are not able to, lets block
                isBlocking = true
            }
        }
        return nil
    }
    
    let clonerStages = ["cloner_stage1","cloner_stage2"]
    
    func attachClonerStage() {
        let sprite = world.sprite.get(entity)
        let stage = entitySprite(any(clonerStages))
        stage.size = world.gs.getSize(FactoredSizes.ScalingFactor.Enemy)
        sprite.node.addChild(stage)
    }
    
}