//
//  CorrectZIndex.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


class CorrectZIndex : EntityAction {
    override var description:String { return "CorrectZIndex" }
    let targetRow:Int
    
    init(entity: Entity, world: WorldMapper, row: Int) {
        self.targetRow = row
        super.init(entity: entity, world: world)
    }
    
    override func perform() -> SKAction? {
        let sprite = world.sprite.get(entity)
        sprite.rootNode.zPosition = EntityFactory.EntityZIndex.GetGridIndex(targetRow)
        return nil
    }
}
