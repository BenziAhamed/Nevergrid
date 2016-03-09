//
//  AnimationSystem.swift
//  gettingthere
//
//  Created by Benzi on 04/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import CoreImage

class AnimationSystem : System {
    
    override init(_ world:WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.EnemyDeath, handler: self)
        world.eventBus.subscribe(GameEvent.ClonerDeath, handler: self)
        world.eventBus.subscribe(GameEvent.CoinCollected, handler: self)
        world.eventBus.subscribe(GameEvent.ZoneKeyCollected, handler: self)
        world.eventBus.subscribe(GameEvent.CellDestroyed, handler: self)
        world.eventBus.subscribe(GameEvent.GameOver, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyEnraged, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyCalmed, handler: self)
        world.eventBus.subscribe(GameEvent.PortalDestroyed, handler: self)
        world.eventBus.subscribe(GameEvent.PowerupCollected, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyFrozen, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyUnfrozen, handler: self)
        world.eventBus.subscribe(GameEvent.PlayerTeleportStarted, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyCreated, handler: self)
        world.eventBus.subscribe(GameEvent.DoPlayerMove, handler: self)
    }
    
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        case GameEvent.EnemyDeath:              onEnemyDeath(data as! Entity)
        case GameEvent.ClonerDeath:             clonerDeath(data as! Entity)
        case GameEvent.CoinCollected:           collectCoin(data as! Entity)
                                                //showStars()
        case GameEvent.ZoneKeyCollected:        onZoneKeyCollected(data as! Entity)
        case GameEvent.CellDestroyed:           onCellDestroyed(data as! Entity)
        case GameEvent.GameOver:                onGameOver(data as! GameOverReason)
        case GameEvent.EnemyEnraged:            onEnemyEnraged(data as! Entity)
        case GameEvent.EnemyCalmed:             onEnemyCalmed(data as! Entity)
        case GameEvent.PortalDestroyed:         onPortalDestroyed(data as! Entity)
        case GameEvent.PowerupCollected:        onPowerupCollected(data as! Entity)
        case GameEvent.EnemyFrozen:             freezeEnemy(data as! Entity)
        case GameEvent.EnemyUnfrozen:           unfreezeEnemy(data as! Entity)
        case GameEvent.PlayerTeleportStarted:   firePortal(data as! Entity)
        case GameEvent.EnemyCreated:            enemyCreated(data as! Entity)
        case GameEvent.DoPlayerMove:            showPlayerMoveIndication(data as! UInt)
        default: break
        }
    }
    
    
    func showPlayerMoveIndication(direction:UInt) {
        if direction == Direction.None {
            let playerSprite = world.sprite.get(world.mainPlayer).node

            
            let tapRing = entitySprite("tap_ring")
            tapRing.position = playerSprite.position
            tapRing.size = playerSprite.size
            tapRing.zPosition = EntityFactory.EntityZIndex.Goal

            world.scene!.worldNode.addChild(tapRing)
            tapRing.runAction(
                SKAction.scaleBy(2.0, duration: 0.4)
                .alongside(SKAction.fadeOutWithDuration(0.4))
                    .followedBy(SKAction.removeFromParent())
            )
            
            //playerSprite.runAction(SKAction.wobble())
            //playerSprite.runAction(ActionFactory.sharedInstance.bounce)
        }
    }
    
    func collectCoin(coin:Entity) {
        let node = world.sprite.get(coin).node
        node.zPosition = EntityFactory.EntityZIndex.Top
        node.removeAllActions()
        node.setScale(1.0)
        node.runAction(
            SKAction.moveByX(0.0, y: 0.5*world.gs.sideLength, duration: 0.1)
            .followedBy(SKAction.waitForDuration(0.3))
            .followedBy(SKAction.scaleTo(1.4, duration: 0.2))
            .followedBy(SKAction.scaleTo(0.0, duration: 0.1))
            .followedBy(SKAction.removeFromParent())
        )
    }
    
    
//    func showStars() {
//        
//        let rotate = SKAction.repeatActionForever(SKAction.rotateByAngle( (unitRandom() < 0.5 ? -1.0 : 1.0) * CGFloat(2.0*M_PI), duration: NSTimeInterval(10.0 + 10.0 * unitRandom())))
//        
//        // top
//        for i in 0..<20 {
//            let position = CGPointMake(
//                unitRandom() * world.scene!.frame.width,
//                world.scene!.frame.height
//            )
//            let star = createStar(position, destination: world.scene!.frame.mid())
//            world.scene!.backgroundNode.addChild(star)
//        }
//        // bottom
//        for i in 0..<20 {
//            let position = CGPointMake(
//                unitRandom() * world.scene!.frame.width,
//                0.0
//            )
//            let star = createStar(position, destination: world.scene!.frame.mid())
//            world.scene!.backgroundNode.addChild(star)
//        }
//        // left
//        for i in 0..<20 {
//            let position = CGPointMake(
//                0.0,
//                unitRandom() * world.scene!.frame.height
//            )
//            let star = createStar(position, destination: world.scene!.frame.mid())
//            world.scene!.backgroundNode.addChild(star)
//        }
//        // right
//        for i in 0..<20 {
//            let position = CGPointMake(
//                world.scene!.frame.width,
//                unitRandom() * world.scene!.frame.height
//            )
//            let star = createStar(position, destination: world.scene!.frame.mid())
//            world.scene!.backgroundNode.addChild(star)
//        }
//        
//        
//    }
//    
//    func createStar(position:CGPoint, destination:CGPoint) -> SKSpriteNode {
//        let star = textSprite("star")
//        star.setScale(0.5 + unitRandom() * 0.5)
//        star.position = position
//        
//        
//        let rotate = SKAction.repeatActionForever(
//            SKAction.rotateByAngle(
//                (unitRandom() < 0.5 ? -1.0 : 1.0) * CGFloat(2.0*M_PI),
//                duration: NSTimeInterval(10.0 + 10.0 * unitRandom())
//            )
//        )
//        
//        let timeToDestination = NSTimeInterval(1.0 + unitRandom()*2.0)
//        let move = SKAction.moveTo(destination, duration: timeToDestination)
//        
//        let timeToLive = NSTimeInterval(2.0 + unitRandom())
//        
//        star.runAction(rotate)
//        star.runAction(move)
//        star.runAction(
//            SKAction.fadeOutWithDuration(timeToLive)
//            .followedBy(SKAction.removeFromParent())
//        )
//        
//        return star
//    }
    
    
    func wobblePlayer() {
        
        // don't wobble for the last coin
        if world.goal.entities().count == 1 { return }
        
        // don't wobble if we are sliding
        if world.slide.belongsTo(world.mainPlayer) { return }
        
        let sprite = world.sprite.get(world.mainPlayer)
        sprite.node.runAction(SKAction.wobble())
    }
    
    
    func enemyCreated(e:Entity) {
        let enemy = world.enemy.get(e)
        
        switch(enemy.enemyType) {
            
        case .SliderUpDown:
            let sprite = world.sprite.get(e)
            sprite.node.runAction(ActionFactory.sharedInstance.createMoveUpAndDown(0.02*world.gs.sideLength))
            
        case .SliderLeftRight:
            let sprite = world.sprite.get(e)
            sprite.node.runAction(ActionFactory.sharedInstance.createMoveLeftAndRight(0.02*world.gs.sideLength))
            
        default:break
        }
    }
    
    
    func firePortal(p:Entity) {
        let portal = world.portal.get(p)
        let sprite = world.sprite.get(p)
        let location = world.location.get(p)
        let emitter = SKEmitterNode.emitterNodeWithName("PortalParticle")
        emitter.particlePositionRange = CGVectorMake(world.gs.sideLength/3, world.gs.sideLength/3)
        emitter.particleBlendMode = world.theme.settings.blendMode
        emitter.particleZPosition = EntityFactory.EntityZIndex.Top // EntityFactory.EntityZIndex.GetGridIndex(location.row)
        
        // emitter is blue by default
        if portal.color == PortalColor.Orange {
            let orange = UIColor(red: 245, green: 166, blue: 35)
            let colorSequence = SKKeyframeSequence(keyframeValues: [orange,orange], times: [0.0,1.0])
            emitter.particleColorSequence = colorSequence
            emitter.particleColorBlendFactor = 1.0
        }
        
        sprite.node.addChild(emitter)
        emitter.advanceSimulationTime(NSTimeInterval(emitter.particleLifetime+emitter.particleLifetimeRange))
        emitter.runOneShot(0.5)
        
    }
    
    func freezeEnemy(enemy:Entity) {
        
        let sprite = world.sprite.get(enemy)
        if let c = sprite.node.childNodeWithName("glass") { return } // we already have added a glass node earlier

        let glass = entitySprite("glass")
        glass.name = "glass"
        glass.size = world.gs.getSize(FactoredSizes.ScalingFactor.Glass)
        glass.alpha = 0
        glass.position = CGPointMake(0, world.gs.sideLength)
        sprite.node.addChild(glass)
        
        // animations
        sprite.node.runAction(
            SKAction.colorizeWithColor(
                UIColor.darkGrayColor(),
                colorBlendFactor: 1,
                duration: 0.3)
        )
        
        let angle = (unitRandom() > 0.5 ? 1.0 : -1.0) * unitRandom() * M_PI_8
        
        
        glass.runAction(ActionFactory.sharedInstance.createPopInActionWithoutDelay(glass, destination: CGPointZero)) {
            sprite.node.runAction(
                ActionFactory.sharedInstance.bounce
                    .alongside(SKAction.rotateToAngle(angle, duration: 0.4))
            )
        }
        
        
        let freezeEffect = entitySprite("freeze_effect")
        sprite.node.addChild(freezeEffect)
        freezeEffect.size = world.gs.getSize(FactoredSizes.ScalingFactor.Glass)
        freezeEffect.alpha = 0.0
        freezeEffect.runAction(
            SKAction.scaleTo(2.0, duration: 0.5)
            .alongside(
                SKAction.fadeInWithDuration(0.25)
                .followedBy(SKAction.fadeOutWithDuration(0.25))
            )
            .followedBy(SKAction.removeFromParent())
        )
    }
    
    func unfreezeEnemy(enemy:Entity) {
        let sprite = world.sprite.get(enemy)
        let glass = sprite.node.childNodeWithName("glass")!
        glass.runAction(SKAction.sequence([
            SKAction.shake(0.3),
            ActionFactory.sharedInstance.fadeOut,
            ActionFactory.sharedInstance.removeFromParent
            ]))
        sprite.node.runAction(
            SKAction.colorizeWithColorBlendFactor(0.0, duration: 0.3)
            .alongside(SKAction.rotateToAngle(0.0, duration: 0.4))
        )
    }
    
    
    func onPortalDestroyed(portal:Entity) {
        let sprite = world.sprite.get(portal)
        let remove = [ActionFactory.sharedInstance.fadeOutSlowly, ActionFactory.sharedInstance.removeFromParent]
        sprite.node.runAction(SKAction.sequence(remove))
    }
    
    func onEnemyEnraged(enemy:Entity){
        let sprite = world.sprite.get(enemy)
        sprite.node.runAction(ActionFactory.sharedInstance.shakeFastContinuous, withKey:"enraged-shake")
    }
    
    func onEnemyCalmed(enemy:Entity) {
        let sprite = world.sprite.get(enemy)
        sprite.node.removeActionForKey("enraged-shake")
        sprite.node.runAction(ActionFactory.sharedInstance.stopShaking)
    }
    
    func onGameOver(reason:GameOverReason) {
        if reason.won {
            // make the player jump up with joy!
            // yay!
            let sprite = world.sprite.get(world.mainPlayer)
            sprite.node.runAction(ActionFactory.sharedInstance.createMoveUpAndDown(0.05 * world.gs.sideLength))
        }
    }
    
    func onEnemyDeath(enemy:Entity) {
        if world.freeze.belongsTo(enemy) {
            frozenDeath(enemy)
        } else {
            smokyDeath(enemy)
        }
    }
    
    func clonerDeath(enemy:Entity) {
        let sprite = world.sprite.get(enemy)
        let enemyDeath =
            (
                SKAction.scaleTo(0.0, duration: 0.5)
                .alongside(SKAction.fadeAlphaTo(0.0, duration: 0.5))
            )
            .followedBy(SKAction.removeFromParent())
        sprite.node.runAction(enemyDeath)
    }
    
    func frozenDeath(enemy:Entity) {
        let sprite = world.sprite.get(enemy)
        let deathDuration = 0.5
        let deathAction = SKAction.group([
            SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.5, duration: deathDuration),
            SKAction.scaleTo(0.7, duration: deathDuration),
            SKAction.fadeAlphaTo(0.0, duration: deathDuration)
            ])
        sprite.node.runAction(SKAction.sequence([
            deathAction,
            ActionFactory.sharedInstance.removeFromParent
            ]))
    }
    
    func smokyDeath(enemy:Entity) {
        let sprite = world.sprite.get(enemy)
        
        // create a bunch of smoky puffs
        let puffs = ["puff1","puff2","puff3"]
        for i in 0..<7 {
            
            let puff = entitySprite(any(puffs))
            puff.size = world.gs.getSize(FactoredSizes.ScalingFactor.Enemy)
            puff.setScale(0.5 + 0.3 * unitRandom())
            puff.alpha = 1.0
            
            
            let position = CGPointMake(
                -puff.size.width/2.0 + unitRandom() * puff.size.width,
                -puff.size.height/2.0 + 0.5 * unitRandom() * puff.size.height
            ).add(sprite.node.position)
            
            puff.position = position
            
            let moveDuration = NSTimeInterval(0.5+0.5*unitRandom())
            let moveUpAndGoAway =
                (
                    SKAction.moveByX(0.0, y: puff.size.height * (0.8 + 0.5*unitRandom()), duration: moveDuration)
                    .alongside(SKAction.scaleBy(1.1, duration: moveDuration))
                )
                .followedBy(SKAction.scaleTo(0.0, duration: 0.2))
                .followedBy(SKAction.removeFromParent())
            
            puff.runAction(SKAction.rotateByAngle(CGFloat(-2.0*M_PI), duration: NSTimeInterval(5.0+10.0*unitRandom())))
            
            world.scene!.entitiesNode.addChild(puff)
            puff.zPosition = EntityFactory.EntityZIndex.Enemy+1.0
            puff.runAction(moveUpAndGoAway)
        }
        
        let enemyDeath =
            SKAction.scaleTo(0.0, duration: 0.5)
            .followedBy(SKAction.removeFromParent())
        
        sprite.node.runAction(enemyDeath)
    }
    
    
    func onZoneKeyCollected(item:Entity) {
        let sprite = world.sprite.get(item)
        sprite.node.runAction(
            SKAction.removeFromParent()
        )
    }
    
    func onPowerupCollected(powerup:Entity) {
        let sprite = world.sprite.get(powerup)
        sprite.node.runAction(ActionFactory.sharedInstance.removeFromParent)
    }
    
    func onCellDestroyed(cell:Entity) {
        let cellSprite = world.sprite.get(cell)
        let baseTexture = world.scene!.view!.textureFromNode(cellSprite.node)!
        let basePosition = cellSprite.node.position
        let baseSize = cellSprite.node.size
        cellSprite.node.removeFromParent()
        
        var zoneX:CGFloat, zoneY:CGFloat, stepSize:CGFloat=FactoredSizes.AnimationSystem.stepSizeForFallingCells
        for zoneX = 0.0; zoneX < 1.0; zoneX+=stepSize {
            for zoneY = 0.0; zoneY < 1.0; zoneY+=stepSize {
                let region = CGRectMake(zoneX, zoneY, stepSize, stepSize)
                let crumbleNode = createCrumpleNode(region, baseTexture: baseTexture, origin: basePosition, baseSize: baseSize, scale: stepSize)
                world.scene!.gridNode.addChild(crumbleNode)
                crumbleNode.runAction(ActionFactory.sharedInstance.fallingCrumpAnimation())
            }
        }
        
    }
    
    func createCrumpleNode(region:CGRect, baseTexture:SKTexture, origin:CGPoint, baseSize:CGSize, scale:CGFloat) -> SKSpriteNode {
        let texture = SKTexture(rect: region, inTexture: baseTexture)
        let node = SKSpriteNode(texture:texture)
        node.size = baseSize.scale(scale)
        node.anchorPoint = CGPointZero
        node.position = origin.offset(dx: region.minX*baseSize.width, dy:region.minY*baseSize.height)
        return node
    }
}
