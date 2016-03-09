//
//  EntityFactory.swift
//  gameninja
//
//  Created by Benzi on 19/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: EntityFactory ------------------------------------------

class EntityFactory {
    
    // MARK: EntityZIndex ------------------------------------------
    
    struct EntityZIndex {
        
        static let Hud:CGFloat = 500.0
        static let Background:CGFloat = 0.0
        static let Items:CGFloat = 199.0
        static let Goal:CGFloat = 200.0
        static let Player:CGFloat = 201.0
        static let Enemy:CGFloat = 201.0
        static let Top:CGFloat = 300.0
        
        static func GetGridIndex(row:Int) -> CGFloat {
            return 100.0+CGFloat(row)
        }
    }
    
    
    var world:WorldMapper

    init(world:WorldMapper){
        self.world = world
    }
    
    
    
    func setupGame() {
        createGrid()
        createEntities()
        createPortals()
        world.cache()
        world.setupConditions()
        world.eventBus.raise(GameEvent.GameEntitiesCreated, data: nil)
    }
    
    
    func createEntities() {
        for i in 0..<world.level.levelObjects.count {
            let object = world.level.levelObjects[i]
            switch(object.group) {
            
            case LevelObjectGroup.Player:
                createPlayer(object.location)
            
            case LevelObjectGroup.Item:
                switch object.type! {
                case "goal":
                    createGoal(object.location)
                case let x where x.hasPrefix("zone"):
                    createZoneKey(object)
                default: break
                }
            
            case LevelObjectGroup.Enemy:
                createEnemy(object.location, type: getEnemyType(object.type))
            
            case LevelObjectGroup.Powerup:
                createPowerup(object)
            
            default: continue
            }
        }
    }

    func getEnemyType(name:String) -> EnemyType {
        switch name {
            case "enemy" : return EnemyType.OneStep
            case "twostep" : return EnemyType.TwoStep
            case "cloner": return EnemyType.Cloner
            case "monster" : return EnemyType.Monster
            case "robot": return EnemyType.Robot
            case "slider_updown": return EnemyType.SliderUpDown
            case "slider_leftright": return EnemyType.SliderLeftRight
            case "destroyer" : return EnemyType.Destroyer
            default: return EnemyType.OneStep
        }
    }
    
    
    func createGrid() {
        
        let specialCells = world.level.levelObjects.filter({ $0.group == LevelObjectGroup.Cell })
        
        for c in 0..<world.level.columns {
            for r in 0..<world.level.rows {
                
                let cell = world.level.cells[c,r]!
                let cellPosition = world.gs.getCellPosition(row: r, column: c)
                if cell.walls == Direction.All  {
                    
                    if world.theme.settings.ignoreBlocks {
                        continue
                    }
                    if (cell.blockRoundedness == 0) {
                        continue
                    }

                    cell.type = CellType.Block
                    
                    var blockNodeName:String!
                    switch cell.blockRoundedness {
                    case 21: blockNodeName = "corner_tl"
                    case 22: blockNodeName = "corner_tr"
                    case 23: blockNodeName = "corner_bl"
                    case 24: blockNodeName = "corner_br"
                    case 29: blockNodeName = "corner_top"
                    case 30: blockNodeName = "corner_bottom"
                    case 31: blockNodeName = "corner_left"
                    case 32: blockNodeName = "corner_right"
                    case 35: blockNodeName = "corner_all"
                    case 39: blockNodeName = "corner_diagonal_down"
                    case 40: blockNodeName = "corner_diagonal_up"
                    default: break
                    }
                    
                    blockNodeName = world.theme.getTextureName(blockNodeName)
                    
                    let blockNode = SKSpriteNode(texture: SpriteManager.Shared.grid.texture(blockNodeName))
                    
                    if world.theme.settings.colorizeCells {
                        blockNode.colorBlendFactor = world.theme.settings.cellColorBlendFactor
                        blockNode.color = world.theme.getBlockColor(column: c, row: r)
                    }
                    
                    blockNode.size = CGSizeMake(world.gs.sideLength, world.gs.sideLength+world.gs.cellExtends)
                    blockNode.position = CGPointMake(cellPosition.x, cellPosition.y-world.gs.cellExtends)
                    blockNode.anchorPoint = CGPointZero
                    blockNode.zPosition = EntityZIndex.GetGridIndex(r)
                    
                    world.scene!.gridNode.addChild(blockNode)
                    
                    
                    let cellComponent = CellComponent(type: CellType.Block)
                    
                    if cell.zone > world.level.initialZone {
                        blockNode.alpha = 0
                    }
                    
                    let e = world.manager.createEntity()
                    let sprite = SpriteComponent(node: blockNode)
                    
                    world.manager.addComponent(e, c: cellComponent)
                    world.manager.addComponent(e, c: sprite)
                    world.manager.addComponent(e, c: cell.location)
                    continue
                }
                
                // if this is a special cell
                // add custom changes
                var cellType = CellType.Normal

                for i in 0..<specialCells.count {
                    let levelObject = specialCells[i]
                    let l = levelObject.location
                    if l.row == r && l.column == c {
                        if levelObject.type == "fluffy" {
                            cellType = CellType.Fluffy
                        }
                        else if levelObject.type == "falling" {
                            cellType = CellType.Falling
                        }
                        break
                    }
                }
                
                cell.type = cellType
                
                var cellNodeName = "cell"

                    switch cell.cellRoundedness {
                    case 17: cellNodeName = "cell_tl"
                    case 18: cellNodeName = "cell_tr"
                    case 19: cellNodeName = "cell_bl"
                    case 20: cellNodeName = "cell_br"
                    case 25: cellNodeName = "cell_top"
                    case 26: cellNodeName = "cell_bottom"
                    case 27: cellNodeName = "cell_left"
                    case 28: cellNodeName = "cell_right"
                    case 36: cellNodeName = "cell_all"
                    default: break
                    }
                
                
                if cellType == CellType.Falling {
                    cellNodeName = "falling_" + cellNodeName
                }
                cellNodeName = world.theme.getTextureName(cellNodeName)
                
                
                let cellNode = gridSprite(cellNodeName)
                
                if world.theme.settings.colorizeCells {
                    cellNode.color = world.theme.getCellColor(column: c, row: r)
                    cellNode.colorBlendFactor = world.theme.settings.cellColorBlendFactor
                }
                
                cellNode.size = CGSizeMake(world.gs.sideLength, world.gs.sideLength+world.gs.cellExtends)
                cellNode.position = CGPointMake(cellPosition.x, cellPosition.y-world.gs.cellExtends)
                cellNode.anchorPoint = CGPointZero
                cellNode.zPosition = EntityZIndex.GetGridIndex(r)
                
                
                if cellType == CellType.Fluffy {
                    // add an attachment
//                    let fluffy = gridSprite("cell_attach_fluffy")
//                    fluffy.size = world.gs.getSize(1.0)
//                    fluffy.position = world.gs.childNodePositionForCell
//                    cellNode.addChild(fluffy)
                    
                    // add a roatating spike of death type attachment
                    let angle = (unitRandom() > 0.5 ? 1.0 : -1.0) * 2.0*CGFloat(M_PI)
                    let outerSpikes = gridSprite("cell_attach_fluffy_spike_outer")
                    outerSpikes.size = world.gs.getSize(1.0)
                    outerSpikes.position = world.gs.childNodePositionForCell
                    cellNode.addChild(outerSpikes)
                    outerSpikes.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(angle, duration: 10.0)))
                    
                    
//                    let innerSpikes = gridSprite("cell_attach_fluffy_spike_inner")
//                    innerSpikes.size = world.gs.getSize(1.0)
//                    innerSpikes.position = world.gs.childNodePositionForCell
//                    cellNode.addChild(innerSpikes)
//                    innerSpikes.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(-2.0*CGFloat(M_PI), duration: 10.0)))
                }
            
                world.scene!.gridNode.addChild(cellNode)
                
                // create the cell component
                let e = world.manager.createEntity()
                let sprite = SpriteComponent(node: cellNode)
                
                let cellComponent = CellComponent(type: cellType)
                
                if cell.zone > world.level.initialZone {
                    cellNode.alpha = 0
                }
                
                world.manager.addComponent(e, c: cellComponent)
                world.manager.addComponent(e, c: sprite)
                world.manager.addComponent(e, c: cell.location)
                
                if cell.walls > 0 {
                    // add a wall node
                    let wallNode = gridSprite("wall\(cell.walls)")
                    
                    wallNode.size = CGSizeMake(world.gs.sideLength, 1.125*world.gs.sideLength)
                    
                    wallNode.position = CGPointZero
                    wallNode.anchorPoint = CGPointZero
                    wallNode.color = world.theme.getWallColor()
                    wallNode.colorBlendFactor = 1.0
                    
                    cellNode.addChild(wallNode)
                }
            }
            
        }
    }
    
    
    
    
    func createPortals() {
        
        let portals:[LevelObject] = world.level.levelObjects.filter({ $0.group == LevelObjectGroup.Portal })
        
        for var p=0; p+1<portals.count; p+=2 { // step in pairs
            let p1 = portals[p]
            let p2 = portals[p+1]
            
            let p1component = PortalComponent(destination: p2.location, color: PortalColor.Orange)
            let p2component = PortalComponent(destination: p1.location, color: PortalColor.Blue)
            
            let sprite1 = entitySprite("portal_orange")
            let sprite2 = entitySprite("portal_blue")
            
            let p1sprite = SpriteComponent(node: sprite1)
            let p2sprite = SpriteComponent(node: sprite2)
            
            let adjustedSize = world.gs.getSize(FactoredSizes.ScalingFactor.Portal)
            
            sprite1.size = adjustedSize
            sprite2.size = adjustedSize
            
            sprite1.position = world.gs.childNodePositionForCell
            sprite2.position = world.gs.childNodePositionForCell
            
            
            sprite1.position = world.gs.getEntityPosition(p1.location)
            sprite2.position = world.gs.getEntityPosition(p2.location)
            
            sprite1.zPosition = EntityZIndex.Items
            sprite2.zPosition = EntityZIndex.Items
            
            world.scene!.entitiesNode.addChild(sprite1)
            world.scene!.entitiesNode.addChild(sprite2)
            
            
            // first portal
            let p1entity = world.manager.createEntity()
            world.manager.addComponent(p1entity, c: p1component)
            world.manager.addComponent(p1entity, c: p1sprite)
            world.manager.addComponent(p1entity, c: p1.location)
            
            // second portal
            let p2entity = world.manager.createEntity()
            world.manager.addComponent(p2entity, c: p2component)
            world.manager.addComponent(p2entity, c: p2sprite)
            world.manager.addComponent(p2entity, c: p2.location)
        }
    }
    
    func createPlayer(location:LocationComponent) -> Entity {
        
        let sprite = entitySprite("player")
        sprite.size = world.gs.getSize(FactoredSizes.ScalingFactor.Player)
        sprite.zPosition = EntityZIndex.Player
        sprite.alpha = 0 // initially not visible
        
        let emotion = entitySprite("emotion_happy")
        emotion.size = sprite.size.scale(FactoredSizes.ScalingFactor.EmotionRelatedToBody)
        emotion.name = "emotion"
        sprite.addChild(emotion)
        
        
        world.scene?.entitiesNode.addChild(sprite)
        
        
        let e = world.manager.createEntity()
        let player = PlayerComponent()
        let render = SpriteComponent(node: sprite)
        
        world.manager.addComponent(e, c: player)
        world.manager.addComponent(e, c: location)
        world.manager.addComponent(e, c: render)
        world.playerLocation = location
        world.mainPlayer = e
        
        world.eventBus.raise(GameEvent.PlayerCreated, data: e)
        
        return e
    }
    
    func createEnemy(location:LocationComponent, type:EnemyType) -> Entity {
        switch type {
            
        case .Monster:
            return createMonster(location)
            
        case .Robot:
            return createRobot(location)
            
        case .SliderLeftRight: fallthrough
        case .SliderUpDown:
            return createSlider(type, location)
            
        case .OneStep:
            return createGenericMonster(type, location, "enemy", "emotion_angry")
            
        case .TwoStep:
            return createGenericMonster(type, location, "enemy_twostep", "emotion_angry")
            
        case .Cloner:
            return createGenericMonster(type, location, "enemy_cloner", "emotion_angry")
            
        case .Destroyer:
            return createGenericMonster(type, location, "destroyer", "emotion_angry")
        
        }
    }
    
    
    func constructSpriteNode(name:String, texture:String, size:CGSize) -> SKSpriteNode {
        let node = entitySprite(texture)
        node.name = name
        node.size = size
        return node
    }
    
    func createRobot(location:LocationComponent) -> Entity {
        
        let size = world.gs.getSize(FactoredSizes.ScalingFactor.Enemy)
        
        let robotBase = constructSpriteNode("base",
            texture: "robot_base",
            size: size
        )
        
        let robotBody = constructSpriteNode("body",
            texture: "robot",
            size: size
        )
        
        let robotLightHolder = constructSpriteNode("light_holder",
            texture: "robot_light_holder",
            size: size
        )
        
        let robotLight = constructSpriteNode("light",
            texture: "robot_light",
            size: size
        )
        
        let robotEyes = constructSpriteNode("emotion",
            texture: "robot_eyes",
            size: size.scale(FactoredSizes.ScalingFactor.EmotionRelatedToBody)
        )
        
        let robotScanArea = constructSpriteNode("scan_area", texture: "robot_scan_area", size: size.scale(3.0))
        
        
        robotBase.addChild(robotScanArea)
        robotBase.addChild(robotBody)
        
        robotBody.addChild(robotLightHolder)
        robotBody.addChild(robotLight)
        robotBody.addChild(robotEyes)
        
        
        
        robotLight.alpha = 0.0 // initially off
        
        return createEnemyEntity(EnemyType.Robot, location: location, rootSprite: robotBase)
    }
    
    func createMonster(location:LocationComponent) -> Entity {
        let monsterTexture = any(["monster_1","monster_2"])
        let monsterBody = constructSpriteNode("body",
            texture: monsterTexture,
            size: world.gs.getSize(FactoredSizes.ScalingFactor.Monster)
        )
        
        let monsterEyes = constructSpriteNode("emotion",
            texture: "emotion_monster_angry",
            size: world.gs.getSize(FactoredSizes.ScalingFactor.Monster).scale(FactoredSizes.ScalingFactor.EmotionRelatedToBody)
        )
        
        monsterBody.addChild(monsterEyes)
        
        return createEnemyEntity(EnemyType.Monster, location: location, rootSprite: monsterBody)
    }
    
    func createGenericMonster(type:EnemyType, _ location:LocationComponent, _ bodyTexture:String, _ eyeTexture:String) -> Entity {
        
        let size = world.gs.getSize(FactoredSizes.ScalingFactor.Enemy)
        
        let monsterBody = constructSpriteNode("body",
            texture: bodyTexture,
            size: size
        )
        
        let monsterEyes = constructSpriteNode("emotion",
            texture: eyeTexture,
            size: size.scale(FactoredSizes.ScalingFactor.EmotionRelatedToBody)
        )
        
        monsterBody.addChild(monsterEyes)
        
        return createEnemyEntity(type, location: location, rootSprite: monsterBody)
    }
    
    func createSlider(type:EnemyType, _ location:LocationComponent) -> Entity {
        let size = world.gs.getSize(FactoredSizes.ScalingFactor.Enemy)
        
        let monsterBody = constructSpriteNode("body",
            texture: "slider",
            size: size
        )
        
        let monsterEyes = constructSpriteNode("emotion",
            texture: "emotion_slider_normal",
            size: size.scale(FactoredSizes.ScalingFactor.EmotionRelatedToBody)
        )
        monsterEyes.position = CGPointMake(0, 0.25*world.gs.sideLength)
        
        monsterBody.addChild(monsterEyes)
        
        return createEnemyEntity(type, location: location, rootSprite: monsterBody)
    }
    
    func createEnemyEntity(type:EnemyType, location:LocationComponent, rootSprite:SKSpriteNode) -> Entity {
        
        rootSprite.zPosition = EntityZIndex.Enemy // EntityZIndex.GetGridIndex(location.row)
        rootSprite.position = world.gs.getEnemyPosition(location, type: type)
        rootSprite.alpha = 0.0
        world.scene?.entitiesNode.addChild(rootSprite)
        
        // create entity
        let e = world.manager.createEntity()
        let enemy = EnemyComponent(type: type)
        let render = SpriteComponent(node: rootSprite)
        
        world.manager.addComponent(e, c: enemy)
        world.manager.addComponent(e, c: location)
        world.manager.addComponent(e, c: render)
        
        world.eventBus.raise(GameEvent.EnemyCreated, data: e)
        
        return e
    }
    
    /// creates a clone at the specified location
    func cloneEnemy(fromEnemy:Entity) -> Entity {
        let location = world.location.get(fromEnemy).clone()
        return createGenericMonster(EnemyType.Cloner, location, "enemy_cloner", "emotion_angry")
    }
    
    func createGoal(location:LocationComponent) -> Entity {
        
        let sprite = entitySprite("goal")
        sprite.size = world.gs.getSize(FactoredSizes.ScalingFactor.Item)
        
        sprite.position = world.gs.getEntityPosition(location)
        sprite.zPosition = EntityZIndex.Goal
        world.scene!.entitiesNode.addChild(sprite)
        
        // the level zone system will take care of making goals visible
        sprite.alpha = 0.0
        let goalAction = SKAction.repeatActionForever(
            SKAction.scaleTo(1.2, duration: 0.5)
            .followedBy(SKAction.scaleTo(1.0, duration: 0.5))
        )
        sprite.runAction(goalAction)
        
        let e = world.manager.createEntity()
        let goal = GoalComponent()
        let render = SpriteComponent(node: sprite)
        
        world.manager.addComponent(e, c: goal)
        world.manager.addComponent(e, c: location)
        world.manager.addComponent(e, c: render)
        world.manager.addComponent(e, c: CollectableComponent())
        
        world.level.cells.get(location)!.goal = e
        
        return e
    }
    
    
    func createZoneKey(zoneKeyObject:LevelObject) -> Entity {
        
        let sprite = entitySprite("warp_key") //getNextZoneKey()
        sprite.size = world.gs.getSize(FactoredSizes.ScalingFactor.Item)
        
        
        sprite.position = world.gs.getEntityPosition(zoneKeyObject.location)
        sprite.zPosition = EntityZIndex.Items
        world.scene!.entitiesNode.addChild(sprite)
        
        sprite.alpha = 0.0
        
        let scaleAction = SKAction.repeatActionForever(
            SKAction.scaleTo(1.2, duration: 0.5)
                .followedBy(SKAction.scaleTo(1.0, duration: 0.5))
        )
        sprite.runAction(scaleAction)

        
        let zonePart = NSString(string: zoneKeyObject.type).stringByReplacingOccurrencesOfString("zone", withString: "")
        let zoneID = UInt(NSString(string: zonePart).integerValue)
        
        let e = world.manager.createEntity()
        
        let zone = ZoneKeyComponent(zoneID: zoneID)
        let render = SpriteComponent(node: sprite)
        
        world.manager.addComponent(e, c: zone)
        world.manager.addComponent(e, c: zoneKeyObject.location)
        world.manager.addComponent(e, c: render)
        world.manager.addComponent(e, c: CollectableComponent())
        
        world.level.cells.get(zoneKeyObject.location)!.zoneKey = e
        
        return e
    }
    
    
    /// creates a powerup entity for the specified level object
    func createPowerup(powerup:LevelObject) {
        var type:PowerupType!
        let duration = PowerupDuration.Infinite
        
        // determine the type of powerup
        switch(powerup.type!){
        case "freeze": type = PowerupType.Freeze
        case "slide": type = PowerupType.Slide
        default:break
        }
        
        let sprite = entitySprite("powerup_\(powerup.type)_on")
        sprite.size = world.gs.getSize(FactoredSizes.ScalingFactor.Item)
        
        sprite.position = world.gs.getEntityPosition(powerup.location)
        sprite.zPosition = EntityZIndex.Items
        world.scene!.entitiesNode.addChild(sprite)
        
        sprite.alpha = 0.0
        let scaleAction = SKAction.repeatActionForever(
            SKAction.scaleTo(1.2, duration: 0.5)
                .followedBy(SKAction.scaleTo(1.0, duration: 0.5))
        )
        sprite.runAction(scaleAction)

        
        let spriteComponent = SpriteComponent(node: sprite)
        
        // create the powerup entity
        let p = world.manager.createEntity()
        world.manager.addComponent(p, c: PowerupComponent(type: type, duration: duration))
        world.manager.addComponent(p, c: powerup.location)
        world.manager.addComponent(p, c: SpriteComponent(node: sprite))
        world.manager.addComponent(p, c: CollectableComponent())
        
        world.level.cells.get(powerup.location)!.powerup = p
    }
    
}


