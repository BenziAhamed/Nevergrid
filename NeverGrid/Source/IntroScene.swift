//
//  IntroScene.swift
//  NeverGrid
//
//  Created by Benzi on 15/03/15.
//  Copyright (c) 2015 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class IntroScene: CutScene {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    var curtain:SKSpriteNode!
    var background:SKSpriteNode!
    var stars:[SKSpriteNode] = []
    var player:SKSpriteNode!
    var message:SKSpriteNode!
    var nextButton:WobbleButton!
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        
        // scene curtain
        curtain = SKSpriteNode(texture: nil, color: UIColor.blackColor(), size: frame.size)
        curtain.position = frame.mid()
        hudNode.addChild(curtain)
        
        // background node
        background = SKSpriteNode(imageNamed: "background_cutscene")
        background.size = background.size.aspectFillTo(frame.size)
        background.anchorPoint = CGPointMake(0.5, 1.0)
        background.position = CGPointMake(frame.midX, frame.maxY)
        backgroundNode.addChild(background)
        
        // stars
        for i in 0..<factor(forPhone: 15, forPad: 20) {
            let star = entitySprite("goal")
            star.position = CGPointMake(
                unitRandom() * self.frame.width,
                unitRandom() * self.frame.height * 0.4 + self.frame.height / 2.0
            )
            let scale = 0.05 + unitRandom() * 0.1
            star.setScale( factor(forPhone: scale, forPad: 1.5*scale))
            stars.append(star)
            worldNode.addChild(star)
        }
        
        // animation
        on(CutSceneNotifications.SceneCreated,Callback(self,IntroScene.removeCurtain))//      , "removeCurtain:")// { [weak self] in self!.removeCurtain() }
        on(CutSceneNotifications.SceneVisible,Callback(self,IntroScene.makeStarsFall))//      , "makeStarsFall:")// { [weak self] in self!.makeStarsFall() }
        on(CutSceneNotifications.StarsFallen,Callback(self,IntroScene.animateBackgroundToTop))//       , "animateBackgroundToTop:")// { [weak self] in self!.animateBackgroundToTop() }
        on(CutSceneNotifications.BackgroundMoved,Callback(self,IntroScene.makePlayerAppear))//   , "makePlayerAppear:")// { [weak self] in self!.makePlayerAppear() }
        on(CutSceneNotifications.PlayerEntered,Callback(self,IntroScene.showMessage))//     , "showMessage:")// { [weak self] in self!.showMessage() }
        on(CutSceneNotifications.MessageShown ,Callback(self,IntroScene.showButton))//     , "showButton:")// { [weak self] in self!.showButton() }
        
        raise(CutSceneNotifications.SceneCreated)
    }

    

    
    
    func removeCurtain() {
        curtain.runAction(
            SKAction.fadeOutWithDuration(2.0)
            .followedBy(SKAction.runBlock{ [weak self] in self!.raise(CutSceneNotifications.SceneVisible) })
        )
    }
    
    func makeStarsFall() {
        stars.shuffle()
        var maxDuration:NSTimeInterval = 0.0
        for star in stars {
            let delay = NSTimeInterval( unitRandom() * 0.5 )
            maxDuration = max(maxDuration, delay)
            let moveDown = SKAction.moveByX(0.0, y: -frame.height, duration: 0.5 + delay)
            moveDown.timingMode = SKActionTimingMode.EaseIn
            star.runAction(
                SKAction.wobble2()
                .followedBy(SKAction.waitForDuration(NSTimeInterval(0.5+unitRandom()*0.5)))
                .followedBy(moveDown)
                .followedBy(SKAction.removeFromParent())
            )
        }
        self.runAction(
            SKAction.waitForDuration(3.0 + maxDuration)
                .followedBy(SKAction.runBlock { [weak self] in self!.raise(CutSceneNotifications.StarsFallen) })
        )
    }
    
    func animateBackgroundToTop() {
        let moveBackground = SKAction.moveByX(0.0, y: background.size.height - frame.size.height, duration: 5.0)
        moveBackground.timingMode = SKActionTimingMode.EaseInEaseOut
        background.runAction(
            moveBackground
                .followedBy(SKAction.runBlock { [weak self] in self!.raise(CutSceneNotifications.BackgroundMoved) })
        )
    }
    
    func makePlayerAppear() {
        player = textSprite("player")
        player.position = CGPointMake(frame.midX, -player.size.height)
        worldNode.addChild(player)
        player.runAction(
            SKAction.moveByX(0.0, y: 2.0*player.size.height, duration: 0.5)
            .followedBy(ActionFactory.sharedInstance.bounce)
            .followedBy(SKAction.runBlock { [weak self] in self!.raise(CutSceneNotifications.PlayerEntered) })
        )
    }
    
    func showMessage() {
        message = messageSprite("message_nostar")
        message.anchorPoint = CGPointMake(0.5, 0.0)
        message.position = CGPointMake(player.position.x, player.position.y + player.size.height/2.0)
        message.setScale(0.0)
        worldNode.addChild(message)
        message.runAction(
            SKAction.scaleTo(1.0, duration: 0.5)
            .followedBy(SKAction.runBlock{ [weak self] in self!.raise(CutSceneNotifications.MessageShown) })
        )
    }
    
    func showButton() {
        // next button
        let next = textSprite("okay")
        nextButton = WobbleButton(node: next, action: Callback(self,IntroScene.goToMainMenu))
        let nextButtonPosition = CGPointMake(
            frame.maxX - next.frame.width - 10.0,
            next.frame.height
        )
        nextButton.position = nextButtonPosition
        nextButton.alpha = 0.0
        hudNode.addChild(nextButton)
        nextButton.runAction(
            SKAction.waitForDuration(1.0)
            .followedBy(SKAction.fadeInWithDuration(1.0))
        )
    }
    
    func goToMainMenu() {
        let settings = GameSettings()
        settings.introSeen = true
        settings.save()
        navigation.displayMainMenu()
    }
    
}


