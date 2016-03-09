//
//  GameHintsNode.swift
//  NeverGrid
//
//  Created by Benzi on 15/10/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GameHintsNode: SKNode {
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
    }
    
    weak var gameScene:GameScene?
    var hintsButton:WobbleButton!
    var hintsButtonPosition:CGPoint!
    var nextButton:WobbleButton!
    var hintsNode:HintNode!
    var nextButtonPosition:CGPoint!
    
    var showing:Bool = false
    var shouldLoadAtGameStart:Bool = false
    var hasContent:Bool = false
    
    init(gameScene:GameScene) {
        super.init()
        
        // find out if this level has hints
        // if not, we are simply an empty node
        let level = gameScene.world.level.info
        
        // does this level have hints?
        // if so we need to add a hint node
        if GameLevelHints.sharedInstance.hasHints(level) {
            
            self.gameScene = gameScene
            self.hasContent = true
            let hints = GameLevelHints.sharedInstance.getHints(level)
            
            let gameSettings = GameSettings()
            if gameSettings.hintsShown[level.number] == nil {
                shouldLoadAtGameStart = true
                gameSettings.hintsShown[level.number] = true
                gameSettings.save()
            }
            
            // since we have hints for this level
            // create the buttons
            
            hintsNode = HintNode(hints: hints, frame: gameScene.frame)
            hintsNode.alpha = 0.0
            self.addChild(hintsNode)
            
            // next button
            let next = textSprite("okay")
            nextButton = WobbleButton(node: next, action: Callback(self,GameHintsNode.displayNextHint))
            nextButtonPosition = CGPointMake(
                gameScene.frame.maxX - next.frame.width - 10.0,
                next.frame.height
            )
            nextButton.position = nextButtonPosition.offset(dx: 0.0, dy: -2.0*next.frame.height)
            self.addChild(nextButton)
            
            // hints button
            let help = textSprite("help_mini")
            //let edgeSpace:CGFloat = factor(forPhone: 5.0, forPad: 10.0)
            // top right
            //hintsButtonPosition = CGPointMake(
            //    gameScene.frame.maxX - edgeSpace - help.frame.width/2.0,
            //    gameScene.frame.height - help.frame.height/2.0 - edgeSpace
            //)
            hintsButtonPosition = CGPointMake(gameScene.frame.maxX - help.frame.width, gameScene.frame.height - help.frame.height)
            hintsButton = WobbleButton(node: help, action: Callback(self, GameHintsNode.show))
            hintsButton.position = hintsButtonPosition.offset(dx: 0.0, dy: 2.0*hintsButton.containedNode.frame.height)
            gameScene.hudNode.addChild(hintsButton)
            // add to hud node directly as we move position when hide() and show() is called
            
            self.position = CGPointMake(gameScene.frame.maxX, 0.0)
        }
    }
    
    
    func showHintsButton() {
        hintsButton.runAction(
            SKAction.moveByX(0.0, y: -2.0*hintsButton.containedNode.frame.height, duration: 0.3)
            .followedBy(ActionFactory.sharedInstance.bounce)
        )
    }
    
    func hideHintsButton() {
        hintsButton.runAction(
            SKAction.moveByX(0.0, y: -0.2*hintsButton.containedNode.frame.height, duration: 0.2).timing(SKActionTimingMode.EaseIn)
                .followedBy(SKAction.moveByX(0.0, y: 2.2*hintsButton.containedNode.frame.height, duration: 0.3).timing(SKActionTimingMode.EaseIn))
        )
    }
    
    func displayNextHint() {
        if hintsNode.hasFurtherHints() {
            hintsNode.displayHint()
        } else {
            hintsNode.reset()
            hide()
        }
    }
    
    
    func show() {
        if showing { return }
        showing = true
        
        gameScene!.ignoreTouches = true
        gameScene!.pauseGameNode.hidePauseButton()
        hideHintsButton()
        
        
        // set our position to normal
        self.position = CGPointZero
        
        // show overlay
        gameScene!.overlay.runAction(SKAction.fadeAlphaTo(0.5, duration: 0.3))
        // show hints
        hintsNode.runAction(SKAction.fadeInWithDuration(0.3))
        hintsNode.displayHint()
        // show next button
        nextButton.runAction(
            SKAction.waitForDuration(0.3)
            .followedBy(SKAction.moveTo(nextButtonPosition, duration: 0.2))
            .followedBy(ActionFactory.sharedInstance.bounce)
        )
    }
    
    func hide() {
        if !showing { return }
        showing = false
        
        gameScene!.ignoreTouches = false
        gameScene!.pauseGameNode.showPauseButton()
        
        // hide overlay
        gameScene!.overlay.runAction(SKAction.fadeOutWithDuration(0.3))
        // hide hints
        hintsNode.runAction(SKAction.fadeOutWithDuration(0.3)) {
            // move ourself out of the way
            [weak self] in
            self!.position = CGPointMake(self!.gameScene!.frame.maxX, 0.0)
        }
        // hide next button
        nextButton.runAction(
            SKAction.moveByX(0.0, y: -2.0*nextButton.containedNode.frame.height, duration: 0.2)
        )
        
        showHintsButton()

    }
    
    
}