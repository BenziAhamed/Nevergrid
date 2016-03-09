//
//  GameOverSceneBase.swift
//  NeverGrid
//
//  Created by Benzi on 23/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameOverSceneBase : NavigatingScene {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    var reason:GameOverReason!
    var levelItem:LevelItem!
    //var mainHeader:TextNode!
    
    var actionButton:WobbleButton!
    var levelsButton:WobbleButton!
    var homeButton:WobbleButton!
    var callback:TargetAction!
    var imagePosition:CGPoint = CGPointZero
    
    init(reason:GameOverReason, levelItem:LevelItem, context:NavigationContext) {
        self.reason = reason
        self.levelItem = levelItem
        super.init(context:context)
    }
    
//    func setHeader(text:String) {
//        mainHeader.text = text
//        mainHeader.render()
//    }
    
    func setAction(text:String, _ callback:TargetAction) {
        let action = textSprite(text)
        self.callback = callback
        actionButton = WobbleButton(node: action, action: Callback(self, GameOverSceneBase.runActionCallback))
        let targetPosition = CGPointMake(self.frame.midX, 0.7*action.frame.height)
        actionButton.position = CGPointMake(self.frame.midX, -action.frame.height)
        worldNode.addChild(actionButton)
        
        actionButton.runAction(
            SKAction.moveTo(targetPosition, duration: 0.3).timing(SKActionTimingMode.EaseOut)
            .followedBy(ActionFactory.sharedInstance.bounce)
        )
        
        let buttonsHeight = targetPosition.y + actionButton.containedNode.frame.height/2.0
        imagePosition = CGPointMake(
            self.frame.midX,
            (self.frame.height - buttonsHeight) / 2.0 + buttonsHeight
        )
        
        
        // levels button
        let levels = textSprite("levels_gameover")
        levelsButton = WobbleButton(node: levels, action: Callback(self, GameOverSceneBase.goToLevels))
        let levelsButtonPosition = CGPointMake(self.frame.maxX - levels.frame.width - 10.0, targetPosition.y)
        levelsButton.position = levelsButtonPosition.offset(dx: 0.0, dy: -2.0*action.frame.height)
        worldNode.addChild(levelsButton)
        
        levelsButton.runAction(
            SKAction.waitForDuration(0.3)
            .followedBy(SKAction.moveTo(levelsButtonPosition, duration: 0.3).timing(SKActionTimingMode.EaseOut))
            //.followedBy(ActionFactory.sharedInstance.bounce)
        )
        
        
        // home button
        let home = textSprite("home_gameover")
        homeButton = WobbleButton(node: home, action: Callback(self, GameOverSceneBase.goToHomeScreen))
        let homeButtonPosition = CGPointMake(home.frame.width + 10.0, targetPosition.y)
        homeButton.position = homeButtonPosition.offset(dx: 0.0, dy: -2.0*action.frame.height)
        worldNode.addChild(homeButton)
        
        homeButton.runAction(
            SKAction.waitForDuration(0.3)
            .followedBy(SKAction.moveTo(homeButtonPosition, duration: 0.3).timing(SKActionTimingMode.EaseOut))
            //.followedBy(ActionFactory.sharedInstance.bounce)
        )
    }
    
    func dismiss(buttons:[SKNode], action:()->()) {
        var delay:NSTimeInterval = 0.0
        for button in buttons {
            button.runAction(
                SKAction.waitForDuration(delay)
                .followedBy(SKAction.moveByX(0.0, y: -button.position.y, duration: 0.3))
            )
            delay += 0.2
        }
        self.runAction(SKAction.waitForDuration(delay-0.2), completion: action)
    }
    
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setBackgroundImage( "background_darkgray" )
        showLevelNumber()
        
//        // header text
//        mainHeader = TextNode()
//        mainHeader.text = ""
//        mainHeader.alpha = 0.8
//        mainHeader.fontSize = FontSize.GameOverPrimary
//        mainHeader.position = CGPointMake(frame.midX, frame.maxY - mainHeader.fontSize/2.0 - factor2(forPhone: 15.0, forPhone3x: 25.0, forPad: 50.0))
//        mainHeader.render()
//        worldNode.addChild(mainHeader)
//        mainHeader.runAction(SKAction.wobble())
    }
    
    func showLevelNumber() {

        let menuBar = MenuBar()
        
        // level node
        let x:CGFloat = frame.width
        let y:CGFloat = frame.height - FontSize.HudTextNodeTextSize/2.0 - factor(forPhone: 10, forPad: 20)
        let position = CGPointMake(x,y)
        
        let levelNode = HudNode(image:"hud_level", text:"\(levelItem.number)")
        levelNode.position = position
        levelNode.alpha = 0.7
        menuBar.addRight(levelNode)
        
        hudNode.addChild(menuBar)
    }
    
    func runActionCallback() {
        callback.performAction()
    }
    
    func goToHomeScreen() {
        navigation.displayMainMenu()
    }
    
    func goToLevels() {
        navigation.goToLevelScene(context)
    }
    
}
