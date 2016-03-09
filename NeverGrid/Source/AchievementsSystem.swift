//
//  AchievementsSystem.swift
//  NeverGrid
//
//  Created by Benzi on 09/03/15.
//  Copyright (c) 2015 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


class AchievementsSystem : System {
    
    var coinInfoNode:SKSpriteNode!
    
    override init(_ world:WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.GameStarted, handler: self)
        world.eventBus.subscribe(GameEvent.CoinCollected, handler: self)
        world.eventBus.subscribe(GameEvent.SceneLoaded, handler: self)
    }

    override func handleEvent(event:Int, _ data:AnyObject?) {
        
        switch event {
            
            
        case GameEvent.SceneLoaded:
            initialize()
            break
        
        case GameEvent.GameStarted:
            displayChapterUnlocked()
            break
            
        case GameEvent.CoinCollected:
            displayCoinMessage()
            break
            
        default:
            break
        }
    }
    
    
    func initialize() {
        coinInfoNode = textSprite("achievement_goal")
        coinInfoNode.position = CGPointMake(world.scene!.frame.midX, world.scene!.frame.maxY + coinInfoNode.frame.height)
        
        // e.g. "2 / 3" coins
        // static part of coins collected update message
        let coinLabelStatic = SKLabelNode(fontNamed: "AvenirNext-Bold")
        coinLabelStatic.fontColor = UIColor.whiteColor()
        coinLabelStatic.fontSize = factor(forPhone: 25.0, forPad: 37.5)
        coinLabelStatic.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        coinLabelStatic.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        coinLabelStatic.name = "coinLabelStatic"
        coinLabelStatic.text = " / \(world.state.targetCoins)"
        coinLabelStatic.position = CGPointMake(0.4*coinInfoNode.frame.width, 4.0)
        coinInfoNode.addChild(coinLabelStatic)
        
        // dynamic part of coins collected
        let coinLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        coinLabel.fontColor = UIColor.whiteColor()
        coinLabel.fontSize = factor(forPhone: 25.0, forPad: 37.5)
        coinLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        coinLabel.name = "coinLabel"
        coinLabel.text = "0"
        coinLabel.position = CGPointMake(coinLabelStatic.position.x - coinLabelStatic.frame.width - 6.0, 4.0)
        coinInfoNode.addChild(coinLabel)
        
        world.scene!.hudNode.addChild(coinInfoNode)
    }
    
    func displayCoinMessage() {
        coinInfoNode.removeActionForKey("coin-message-show")
        let messageShow =
            SKAction.moveTo(CGPointMake(world.scene!.frame.midX, world.scene!.frame.maxY - coinInfoNode.frame.height/2.0), duration: 0.2)
            .followedBy(SKAction.waitForDuration(3.0))
            .followedBy(SKAction.moveTo( CGPointMake(world.scene!.frame.midX, world.scene!.frame.maxY + coinInfoNode.frame.height), duration: 0.2))
        coinInfoNode.runAction(messageShow, withKey: "coin-message-show")
        
        let coinLabel = coinInfoNode.childNodeWithName("coinLabel")! as! SKLabelNode
        coinLabel.text = "\(world.state.coinsCollected)"
        
//        let coinLabelTexture = world.scene!.view!.textureFromNode(coinLabel)
//        let expandingNode = SKSpriteNode(texture: coinLabelTexture)
//        expandingNode.position = coinLabel.position.offset(dx: -coinLabel.frame.width/2.0, dy: 0.0)
//        expandingNode.size = coinLabel.frame.size
//        coinInfoNode.addChild(expandingNode)
//        
//        expandingNode.runAction(
//            SKAction.fadeOutWithDuration(0.2)
//            .alongside(SKAction.scaleTo(2.0, duration: 0.2))
//                .followedBy(SKAction.removeFromParent())
//        )

    }
    
    
    func displayChapterUnlocked() {
        if world.level.info.shouldDisplayChapterUnlocked() {
            let message = textSprite("achievement_chapter")
            
            let targetPosition = CGPointMake(world.scene!.frame.midX, 0.7*message.frame.height)
            let hidePosition = CGPointMake(world.scene!.frame.midX, -2.0*message.frame.height)
            
            message.position = hidePosition
            world.scene!.hudNode.addChild(message)
            
            message.runAction(
                SKAction.moveTo(targetPosition, duration: 0.5)
                    .followedBy(ActionFactory.sharedInstance.bounce)
                    .followedBy(SKAction.waitForDuration(5.0))
                    .followedBy(SKAction.moveTo(hidePosition, duration: 0.5))
                    .followedBy(SKAction.removeFromParent())
            )
        }
    }
    
}