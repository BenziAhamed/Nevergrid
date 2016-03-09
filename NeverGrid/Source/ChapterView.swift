//
//  ChapterView.swift
//  MrGreen
//
//  Created by Benzi on 27/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

/// MARK:
class ChapterView : SKNode {
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var chapter:ChapterItem! = nil
    var levelNodeSideLength:CGFloat = factor2(forPhone: 64.0, forPhone3x: 96.0, forPad: 112.0)
    var levelNumberFontSize:CGFloat = factor2(forPhone: 25.0, forPhone3x: 40.0, forPad: 50.0)
    let emotionScale:CGFloat = 0.761904762
    
    var levelNodes = [String:SKSpriteNode]()
    
    init(_ chapter:ChapterItem, nextLevelToPlay:LevelItem?, theme:ThemeManager) {
        super.init()
        self.chapter = chapter
        
        let levelNodeSize:CGSize = CGSizeMake(levelNodeSideLength, levelNodeSideLength*1.125)
        let playerNodeSize:CGSize = CGSizeMake(levelNodeSideLength, levelNodeSideLength).scale(0.9)
        var position = CGPointMake(levelNodeSideLength/2.0, 0.0)
        
        let levelCount = chapter.levels.count-1
        for (index, level) in chapter.levels.enumerate() {
            
            // create the level node grid cell
            let texture = theme.getTextureName(levelTexture(index, levelCount))
            let levelSprite = SKSpriteNode(texture: SpriteManager.Shared.grid.texture(texture))
            levelSprite.size = levelNodeSize
            levelSprite.position = position
            levelSprite.colorBlendFactor = 1.0
            levelSprite.color = UIColor.whiteColor() // theme.getCellColor(column: level.number, row: 0)
            levelSprite.zPosition = 10.0
            
            // if we have not completed this level, we need to fade it out
            // slightly
            if !level.isCompleted {
                levelSprite.alpha = 0.3
            }
            
            
            // apply a shadow beaneath the cell
            let shadowTextureName = shadowTexture(index, levelCount)
            let shadowSprite = SKSpriteNode(texture: SpriteManager.Shared.grid.texture(shadowTextureName))
            shadowSprite.size = levelNodeSize
            shadowSprite.position = position.offset(dx: 0, dy: -levelNodeSize.height/2.0)
            shadowSprite.zPosition = 5.0
            
            
            // add a level number
            let levelNumberSprite = SKLabelNode(fontNamed: FactoredSizes.numberFont)
            levelNumberSprite.text = "\(level.number)"
            levelNumberSprite.fontColor =
                level.isCompleted ?
                    UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8) // black
                :   UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // white
            levelNumberSprite.fontSize = levelNumberFontSize
            levelNumberSprite.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            levelNumberSprite.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            levelNumberSprite.position = CGPointMake(0.0, 0.0625*levelNodeSize.height)
            
            
            if nextLevelToPlay?.levelKey == level.levelKey {
                // add a player sprite to indicate which is the next logical level to complete
                let playerSprite = entitySprite("player")
                playerSprite.size = playerNodeSize
                playerSprite.zPosition = 11.0
                playerSprite.setItem("level", value: level)
                
                let playerEmotion = entitySprite("emotion_happy")
                playerEmotion.size = playerNodeSize.scale(emotionScale)
                playerEmotion.setItem("level", value: level)
                playerSprite.addChild(playerEmotion)
                
                // lets try to move in the player
                let playerTargetPosition = position.offset(dx: 0, dy: levelNodeSize.height*0.125)
                var playerStartPosition = playerTargetPosition.offset(dx: -levelNodeSideLength, dy: 0.0)
                if level.isFirstLevelInChapter {
                    playerStartPosition = playerTargetPosition.offset(dx: 0.0, dy: +levelNodeSideLength)
                    playerSprite.alpha = 0.0
                }
                playerSprite.position = playerStartPosition
                let moveIn = ActionFactory.sharedInstance.createPopInActionWithoutDelay(playerSprite, destination: playerTargetPosition)
                let fadeIn = SKAction.fadeInWithDuration(0.3)
                let arrive = SKAction.group([fadeIn,moveIn])
                if level.isFirstLevelInChapter {
                    playerSprite.runAction(SKAction.sequence([arrive,ActionFactory.sharedInstance.playPop]))
                } else {
                    playerSprite.runAction(arrive)
                }
                
                self.addChild(playerSprite)
            }
            
            
            // level sprite will hold a reference to the level for later reference
            // also we save a reference to the level sprite based on the level key
            levelSprite.setItem("level", value: level)
            levelNodes[level.levelKey as String] = levelSprite
            
            
            // add the sprites
            levelSprite.addChild(levelNumberSprite)
            self.addChild(levelSprite)
            self.addChild(shadowSprite)
            
            
            
            // update the position offset to apply to the next level node
            position = position.offset(dx: levelNodeSideLength, dy: 0)
        }
    }
    
    
    func levelTexture(index:Int, _ levelCount:Int) -> String {
        if levelCount == 0 { return "cell_all" }
        else if index == 0 { return "cell_left" }
        else if index == levelCount { return "cell_right" }
        else { return "cell" }
    }
    
    func shadowTexture(index:Int, _ levelCount:Int) -> String {
        if levelCount == 0 { return "shadow_bottom" }
        else if index == 0 { return "shadow_left" }
        else if index == levelCount { return "shadow_right" }
        else { return "shadow_mid" }
    }
}
