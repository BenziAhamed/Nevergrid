//
//  GameWonScene.swift
//  NeverGrid
//
//  Created by Benzi on 20/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import Social

class GameWonScene : GameOverSceneBase {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var gameState:GameState!
    var levelLoading = false

    init(reason:GameOverReason, levelItem:LevelItem, state:GameState, context:NavigationContext) {
        self.gameState = state
        super.init(reason:reason, levelItem:levelItem, context:context)
        
        // TODO: do not use level state, use game state instead (maybe?)
        let gameOverState = LevelState(completed: true, moves: gameState.movesMade)
        LevelProgressSystem.markLevelCompleted(levelItem, state: gameOverState)
    }
    
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        //setHeader(any(["cool!","awesome!","yay!","wonderful","super!","yes!"]))
        setAction("continue", Callback(self,GameWonScene.nextLevel))
        
        // center image
        var texture:String!
        texture = any([
            "player_elated",
            "player_olympic",
            "player_confetti",
            "player_cloud_friends",
            "player_hat"
        ])
        let playerSprite = gameOverSprite(texture)
        playerSprite.position = imagePosition
        worldNode.addChild(playerSprite)
        playerSprite.runAction(SKAction.scaleTo(1.1, duration: 1.0))
        
        
        // twitter button
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let twitter = textSprite("twitter")
            let twitterButton = WobbleButton(node: twitter, action: Callback(self, GameWonScene.postTwitterMessage))
            twitterButton.position = CGPointMake(
                twitter.frame.width,
                frame.height - twitter.frame.height
            )
            worldNode.addChild(twitterButton)
        }
    }
    
    
    func postTwitterMessage() {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.Twitter,
                object:nil,
                userInfo:["message":"I just completed level \(levelItem.number) in #nevergrid"]
        )        
    }
    
    func postFacebookMessage() {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.Facebook,
                object:nil,
                userInfo:["message":"I just completed level \(levelItem.number) in #nevergrid"]
        )
    }
    
    
    func nextLevel() {
        
        let nextLevel = LevelProgressSystem.getNextLevelInSequence(levelItem)
        context.selectedLevel = nextLevel.info
        context.selectedChapter = nextLevel.info.chapter
        self.navigation.displayGameScene(
            GameScene(level: nextLevel, context: self.context)
        )
        
    }

}


