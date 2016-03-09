//
//  PauseGameNode.swift
//  NeverGrid
//
//  Created by Benzi on 12/10/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class PauseGameNode: SKNode {
    required init?(coder:NSCoder) {
        super.init(coder: coder)
    }
    
    weak var gameScene:GameScene?
    var pauseButton:WobbleButton!
    
    var cancelButton:WobbleButton!
    var quitButton:WobbleButton!
    var reloadButton:WobbleButton!
    var levelsButton:WobbleButton!
    
    
    var levelNumberPosition:CGPoint!
    var quitButtonPosition:CGPoint!
    var reloadButtonPosition:CGPoint!
    var cancelButtonPosition:CGPoint!
    var levelsButtonPosition:CGPoint!
    
    var buttons:SKNode!
    
    var activated:Bool = false
    
    init(gameScene:GameScene) {
        super.init()
        
        self.gameScene = gameScene
        
        // buttons
        buttons = SKNode()
        self.addChild(buttons)
        buttons.alpha = 0.0
        
        var position = CGPointMake( gameScene.frame.midX, gameScene.frame.height - 5.0)
        let spacing: CGFloat = 10.0
        
        // level number
        let levelNumber = SKLabelNode(fontNamed: "Luckiest Guy")
        levelNumber.fontColor = UIColor(red: 119, green: 113, blue: 33)
        levelNumber.fontSize = factor2(forPhone: 48.0, forPhone3x: 50.0, forPad: 75.0)
        levelNumber.text = "Level \(gameScene.world.level.info.number)"
        levelNumber.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelNumber.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        //levelNumber.position = CGPointMake(0.0, factor(forPhone: 5.0, forPad: 7.0)) // slight to the top
        let levelNumberNode = textSprite("level_holder")
        levelNumberNode.addChild(levelNumber)
        position = position.offset(dx: 0.0, dy: -(levelNumberNode.frame.height/2.0 + spacing) )
        levelNumberNode.position = position
        
        levelNumberPosition = position
        buttons.addChild(levelNumberNode)
        

        // quit button
        quitButton = WobbleButton(node: textSprite("quit"), action: Callback(gameScene, GameScene.closeScene))
        position = position.offset(dx: 0.0, dy: -(levelNumberNode.frame.height + spacing) )
        quitButtonPosition = position
        buttons.addChild(quitButton)
        
        
        // reload button
        reloadButton = WobbleButton(node: textSprite("reload"), action: Callback(gameScene, GameScene.reloadScene))
        position = position.offset(dx: 0.0, dy: -(reloadButton.containedNode.frame.height + spacing) )
        reloadButtonPosition = position
        buttons.addChild(reloadButton)
        
        // cancel button
        cancelButton = WobbleButton(node: textSprite("cancel"), action: Callback(self, PauseGameNode.dismiss))
        position = position.offset(dx: 0.0, dy: -(cancelButton.containedNode.frame.height + spacing) )
        cancelButtonPosition = position
        buttons.addChild(cancelButton)

        // centre the buttons node
        let buttonsOffset = -(position.y - cancelButton.containedNode.frame.height/2.0)/2.0
        buttons.position = buttons.position.offset(dx: 0.0, dy: buttonsOffset)

        
        // levels button
        let levels = textSprite("levels")
        levelsButton = WobbleButton(node: levels, action: Callback(gameScene, GameScene.goToLevels))
        levelsButtonPosition = CGPointMake(gameScene.frame.maxX - levels.frame.width - 10.0, levels.frame.height)
        levelsButton.position = levelsButtonPosition.offset(dx: 0.0, dy: -2.0*levelsButtonPosition.y)
        self.addChild(levelsButton)
        
        // pause button
        let pause = textSprite("pause")
        
        let pausePosition = CGPointMake( pause.frame.width, gameScene.frame.height - pause.frame.height )
        pauseButton = WobbleButton(node: pause, action: Callback(self, PauseGameNode.activate))
        pauseButton.position = pausePosition.offset(dx: 0.0, dy: 2.0*pauseButton.containedNode.frame.height)
        self.addChild(pauseButton)
        
        hideButtons()
    }
    
    func showPauseButton() {
        pauseButton.runAction(
            SKAction.moveByX(0.0, y: -2.0*pauseButton.containedNode.frame.height, duration: 0.3)
                .followedBy(ActionFactory.sharedInstance.bounce)
        )
    }
    
    func hidePauseButton() {
        pauseButton.runAction(
            SKAction.moveByX(0.0, y: -0.2*pauseButton.containedNode.frame.height, duration: 0.2).timing(SKActionTimingMode.EaseIn)
                .followedBy(SKAction.moveByX(0.0, y: 2.2*pauseButton.containedNode.frame.height, duration: 0.3).timing(SKActionTimingMode.EaseIn))
        )
    }
    
    func hideButtons() {
        let position = CGPointMake(gameScene!.frame.midX, -quitButton.containedNode.frame.height)
        quitButton.position = position
        reloadButton.position = position
        cancelButton.position = position
    }

    
    func activate() {

        if activated { return }
        activated = true
        gameScene!.ignoreTouches = true
        if gameScene!.gameHintsNode.hasContent {
           gameScene!.gameHintsNode.hideHintsButton()
        }
        
        // move pause button up
        hidePauseButton()
        
        // darken screen
        gameScene!.overlay.runAction(SKAction.fadeAlphaTo(0.5, duration: 0.3))
        
        
        // show buttons
        buttons.runAction(SKAction.fadeInWithDuration(0.3))
        
        quitButton.runAction(
            SKAction.moveTo(quitButtonPosition, duration: 0.5)
        )
        reloadButton.runAction(
            SKAction.waitForDuration(0.1)
            .followedBy(SKAction.moveTo(reloadButtonPosition, duration: 0.5))
        )
        cancelButton.runAction(
            SKAction.waitForDuration(0.2)
            .followedBy(SKAction.moveTo(cancelButtonPosition, duration: 0.5))
        )
        
        levelsButton.runAction(
            SKAction.waitForDuration(0.3)
            .followedBy(SKAction.moveTo(levelsButtonPosition, duration: 0.2))
            .followedBy(ActionFactory.sharedInstance.bounce)
        )
    }
    
    func dismiss() {
        
        if !activated { return }
        activated = false
        
        gameScene!.ignoreTouches = false
        if gameScene!.gameHintsNode.hasContent {
            gameScene!.gameHintsNode.showHintsButton()
        }
        
        levelsButton.runAction(
            SKAction.moveTo(levelsButtonPosition.offset(dx: 0.0, dy: -2.0*levelsButton.containedNode.frame.height), duration: 0.2)
        )
            
        
        
        // hide buttons
        buttons.runAction(SKAction.fadeOutWithDuration(0.3))
        {
            [weak self] in
            self!.hideButtons()
        }
        // undarken screen
        gameScene!.overlay.runAction(SKAction.fadeOutWithDuration(0.3))
        
        // move pause button down
        showPauseButton()
    }
    
}

