//
//  WorldMapper.swift
//  OnGettingThere
//
//  Created by Benzi on 21/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class WorldMapper {
    
    var location:   ComponentMapper<LocationComponent>
    var enemy:      ComponentMapper<EnemyComponent>
    var player:     ComponentMapper<PlayerComponent>
    var sprite:     ComponentMapper<SpriteComponent>
    var cell:       ComponentMapper<CellComponent>
    var portal:     ComponentMapper<PortalComponent>
    var goal:       ComponentMapper<GoalComponent>
    var powerup:    ComponentMapper<PowerupComponent>
    var freeze:     ComponentMapper<FreezeComponent>
    var slide:      ComponentMapper<SlideComponent>
    var zoneKey:    ComponentMapper<ZoneKeyComponent>
    var collectable:ComponentMapper<CollectableComponent>

    
    var manager: EntityManager
    var level:Level
    var gs:GridSystem
    var state:GameState
    var eventBus:EventBus
    
    var conditions:[GameCondition]!
    var theme:ThemeManager!
    
    weak var scene:GameScene?
    
    init(manager m:EntityManager, level:Level, gs:GridSystem, scene:GameScene) {
        self.location =     ComponentMapper<LocationComponent>    (type:ComponentType.Location,   manager:m)
        self.enemy =        ComponentMapper<EnemyComponent>       (type:ComponentType.Enemy,      manager:m)
        self.player =       ComponentMapper<PlayerComponent>      (type:ComponentType.Player,     manager:m)
        self.sprite =       ComponentMapper<SpriteComponent>      (type:ComponentType.Sprite,     manager:m)
        self.cell =         ComponentMapper<CellComponent>        (type:ComponentType.Cell,       manager:m)
        self.portal =       ComponentMapper<PortalComponent>      (type:ComponentType.Portal,     manager:m)
        self.goal =         ComponentMapper<GoalComponent>        (type:ComponentType.Goal,       manager:m)
        self.powerup =      ComponentMapper<PowerupComponent>     (type:ComponentType.Powerup,    manager:m)
        self.freeze =       ComponentMapper<FreezeComponent>      (type:ComponentType.Freeze,     manager:m)
        self.slide =        ComponentMapper<SlideComponent>       (type:ComponentType.Slide,      manager:m)
        self.zoneKey =      ComponentMapper<ZoneKeyComponent>     (type:ComponentType.ZoneKey,    manager:m)
        self.collectable =  ComponentMapper<CollectableComponent> (type:ComponentType.Collectable,manager:m)

        self.manager = m
        self.level = level
        self.gs = gs
        self.scene = scene
        self.eventBus = EventBus()
        self.state = GameState()
    }
    
    func setupConditions()
    {
        self.conditions = GameConditionFactory.generateConditions(self)
    }
    
    
    // cached fields
    var portalCache = LocationBasedCache<Entity>()
    var cellCache = LocationBasedCache<Entity>()
    
    var mainPlayer:Entity!
    var playerLocation:LocationComponent!
    
    /// updates references to static items in the world
    func cache() {

        portalCache.clear()
        cellCache.clear()
        
        for p in portal.entities() {
            let locationComponent = location.get(p)
            portalCache.set(locationComponent, item: p)
        }
        for c in cell.entities() {
            let cellComponent = cell.get(c)
            let locationComponent = location.get(c)
            cellCache.set(locationComponent, item: c)
        }
    }
}
