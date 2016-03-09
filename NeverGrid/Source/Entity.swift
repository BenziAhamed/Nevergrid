//
//  Entity.swift
//  gameninja
//
//  Created by Benzi on 19/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

// MARK: Entity ------------------------------------------

class Entity: Equatable {
    var id:Int
    
    init(id:Int){
        self.id = id
    }
}

func ==(a:Entity, b:Entity) -> Bool {
    return a.id == b.id
}

// MARK: EntityManager ------------------------------------------

class EntityManager {

    struct EntityId{
        static var lowestIdCreated:Int = 0
    }
        
    var entities:[Int]
    var componentsByType:[ComponentType:[Int:Component]]
    
    init(){
        entities = []
        componentsByType = [ComponentType:[Int:Component]]()
    }
    
    func createEntityId() -> Int {
        if EntityId.lowestIdCreated < Int.max {
            return EntityId.lowestIdCreated++
        } else {
            for i in 1..<Int.max {
                if !entities.contains(i) {
                    return i
                }
            }
        }
        return 0
    }
    
    func createEntity() -> Entity {
        let e = Entity(id: createEntityId())
        self.entities.append(e.id)
        return e
    }
    
    func removeEntity(e:Entity) {
        
        for k in componentsByType.keys {
            // get value
            var components = componentsByType[k]!
            if let componentForEntity = components[e.id] {
                components.removeValueForKey(e.id)
                // update back
                componentsByType[k] = components
            }
        }
        for i in 0..<entities.count {
            if entities[i] == e.id {
                entities.removeAtIndex(i)
                break
            }
        }
    }
    
    func entityExists(e:Entity) -> Bool {
        for id in entities {
            if e.id == id { return true }
        }
        return false
    }
    
    func addComponent(e:Entity, c:Component){
        if componentsByType[c.type] == nil {
            componentsByType[c.type] = [Int:Component]()
        }
        
        // get value
        var componentMap = componentsByType[c.type]!
        componentMap[e.id] = c
        // update back
        componentsByType[c.type] = componentMap
        
    }
    
    func removeComponent(e:Entity, c:Component) {
        if let componentMap = componentsByType[c.type] {
            // get value
            var componentMap = componentsByType[c.type]!
            componentMap[e.id] = nil
            // update back
            componentsByType[c.type] = componentMap
        }
    }
    
    func getComponent(e:Entity, type:ComponentType) -> Component? {
        if let componentSet = componentsByType[type] {
            if let component = componentSet[e.id] {
                return component
            }
        }
        return nil
    }
    
    func hasComponent(e:Entity, type:ComponentType) -> Bool {
        if let c = getComponent(e, type: type) { return true }
        return false
    }
    
    func getEntitiesWithComponent(type:ComponentType) -> [Entity] {
        if let components = componentsByType[type] {
            var entities = [Entity]()
            for k in components.keys {
                entities.append(Entity(id: k))
            }
            return entities
        }
        return []
    }
    
}


