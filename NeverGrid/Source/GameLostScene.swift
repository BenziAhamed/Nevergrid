//
//  GameLostScene.swift
//  NeverGrid
//
//  Created by Benzi on 19/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GameLostScene : GameOverSceneBase {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(reason:GameOverReason, levelItem:LevelItem, context:NavigationContext) {
        super.init(reason:reason, levelItem:levelItem, context:context)
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setAction("retry", Callback(self,GameLostScene.reloadLevel))
        
        
        // center image
        var texture:String!
        switch reason.state {
        
        case .RanOutOfMoves:
            texture = "player_surprised"

        case .PlayerStuck:
            texture = "player_surprised"
        
        case .PlayerCornered:
            texture = "player_surprised"
            
        case .PlayerCrashedIntoEnemy:
            texture = "player_crashed"
        
        default:
            texture = any([
                "player_crying",
                "player_injured",
                "player_rip",
                "player_sniff",
                "player_bag"
                ])
        }
        let playerSprite = gameOverSprite(texture)
        playerSprite.position = imagePosition
        worldNode.addChild(playerSprite)
        playerSprite.runAction(SKAction.scaleTo(1.1, duration: 1.0))
        
    }
    
    
    func reloadLevel() {
        self.navigation.displayGameScene(
            GameScene(level: LevelParser.parse(self.levelItem), context: self.context)
        )
    }
}