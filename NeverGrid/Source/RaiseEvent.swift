//
//  RaiseEvent.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class RaiseEvent : EntityAction {
    
    override var description:String {
        return "RaiseEvent<\(___GameEventNames[event]!)>"
    }
    
    var event:Int
    
    init(event:Int, entity: Entity, world: WorldMapper) {
        self.event = event
        super.init(entity: entity, world: world)
    }
    
    override func perform() -> SKAction? {
        world.eventBus.raise(event, data: entity)
        return nil
    }
}