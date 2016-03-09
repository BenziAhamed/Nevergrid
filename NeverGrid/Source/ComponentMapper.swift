//
//  ComponentMapper.swift
//  gettingthere
//
//  Created by Benzi on 10/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class ComponentMapper<T> {
    
    var type:ComponentType
    weak var manager:EntityManager?
    
    init(type:ComponentType, manager:EntityManager) {
        self.type = type
        self.manager = manager
    }
    
    
    /// gets the mapped component for the entity
    func get(entity:Entity) -> T {
        return manager!.getComponent(entity, type: self.type) as! T
    }
    
    /// returns true if the mapped component belongs to the entity
    func belongsTo(entity:Entity) -> Bool {
        return manager!.hasComponent(entity, type: self.type)
    }
    
    /// returns all entities having the mapped component
    func entities() -> [Entity] {
        return manager!.getEntitiesWithComponent(self.type)
    }
    
}
