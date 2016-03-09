//
//  DieIfOnFluffyCell.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit



/// action that blocks if you land on a fluffy cell
/// raises enemy death event
class DieIfOnFluffyCell : EntityAction {
    
    override var description:String { return "DieIfOnFluffyCell" }
    
    override func perform() -> SKAction? {
        
        // have we landed in a cell that is fluffy?
        let enemyLocation = world.location.get(entity)
        let cell = world.level.cells.get(enemyLocation)!
        if cell.type == CellType.Fluffy {
            cell.occupiedBy = nil
            world.eventBus.raise(GameEvent.EnemyDeath, data: entity)
            isBlocking = true
        }
        
        return nil
    }
}