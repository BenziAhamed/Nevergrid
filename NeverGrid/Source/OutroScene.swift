//
//  OutroScene.swift
//  NeverGrid
//
//  Created by Benzi on 15/03/15.
//  Copyright (c) 2015 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class OutroScene: CutScene {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(context:NavigationContext) {
        self.context = context
        super.init()
    }

    var context:NavigationContext!
    var background:SKSpriteNode!
    var curtain:SKSpriteNode!
    var nextButton:WobbleButton!
    var hints:HintNode!
    var theEnd:SKSpriteNode!
    var forNode:SKSpriteNode!
    var nowNode:SKSpriteNode!
    
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // curtain
        curtain = SKSpriteNode(texture: nil, color: UIColor.blackColor(), size: frame.size)
        curtain.position = frame.mid()
        hudNode.addChild(curtain)
        
        // background
        background = SKSpriteNode(imageNamed: "background_cutscene")
        background.anchorPoint = CGPointMake(0.5, 0.0)
        background.position = CGPointMake(frame.midX, 0.0)
        background.size = background.size.aspectFillTo(frame.size)
        backgroundNode.addChild(background)
        
        
        // hints node
        hints = HintNode(hints: [
            "message_ending_1",
            "message_ending_2",
            "message_ending_3",
            "message_ending_4",
            "message_ending_5"
            ],
            frame: self.frame)
        worldNode.addChild(hints)
        
        // next button
        let next = textSprite("okay")
        nextButton = WobbleButton(node: next, action: Callback(self,OutroScene.handleNext))
        nextButton.position = CGPointMake(
            frame.maxX - next.frame.width - 10.0,
            next.frame.height
        )
        
        // animations
        on(CutSceneNotifications.SceneCreated,Callback(self, OutroScene.removeCurtain)) //{ [weak self] in self!.removeCurtain() }
        on(CutSceneNotifications.SceneVisible,Callback(self, OutroScene.showMessage))//,"showMessage") //{ [weak self] in self!.showMessage() }
        on(CutSceneNotifications.MessageShown,Callback(self, OutroScene.moveBackground))//,"moveBackground") //{ [weak self] in self!.moveBackground() }
        on(CutSceneNotifications.BackgroundMoved,Callback(self, OutroScene.showTheEnd))//,"showTheEnd") //{ [weak self] in self!.showTheEnd() }
        on(CutSceneNotifications.TheEndShown,Callback(self, OutroScene.setupNextButton))//,"setupNextButton") //{ [weak self] in self!.setupNextButton() }
        
        
        raise(CutSceneNotifications.SceneCreated)
    }
    
    func removeCurtain() {
        curtain.runAction(
            SKAction.fadeOutWithDuration(2.0)
            .followedBy(SKAction.runBlock{ [weak self] in self!.raise(CutSceneNotifications.SceneVisible) })
            .followedBy(SKAction.removeFromParent())
        )
    }
    

    
    func showMessage() {
        hudNode.addChild(nextButton)
        hints.displayHint()
    }
    
    func handleNext() {
        if hints.hasFurtherHints() {
            hints.displayHint()
        } else {
            hints.runAction(SKAction.moveByX(0.0, y: -frame.height, duration: 0.4))
            raise(CutSceneNotifications.MessageShown)
        }
    }
    
    func moveBackground() {
        
        // hide button
        nextButton.runAction(SKAction.fadeOutWithDuration(0.0))
        
        
        // move background
        background.runAction(
            SKAction.moveByX(0.0, y: -(background.frame.height-frame.height), duration: 2.0)
            .followedBy(SKAction.runBlock{ [weak self] in self!.raise(CutSceneNotifications.BackgroundMoved) })
        )
        
        
        // move in the end alond with background
        theEnd = textSprite("the_end")
        theEnd.position = CGPointMake(frame.midX, frame.height + theEnd.frame.height)
        worldNode.addChild(theEnd)
        let moveAction = SKAction.moveTo(frame.mid(), duration: 2.5)
        moveAction.timingMode = SKActionTimingMode.EaseOut
        theEnd.runAction(moveAction)
    }
    
    func showTheEnd() {
        
        forNode = textSprite("the_end_for")
        nowNode = textSprite("the_end_now")
        
        forNode.position = CGPointMake(frame.midX - forNode.frame.width/2.0 - 5.0, 0.3 * frame.height)
        nowNode.position = CGPointMake(frame.midX + nowNode.frame.width/2.0 + 5.0, 0.3 * frame.height)
        
        forNode.alpha = 0.0
        nowNode.alpha = 0.0
        
        worldNode.addChild(forNode)
        worldNode.addChild(nowNode)
        
        forNode.runAction(SKAction.waitForDuration(0.5).followedBy(SKAction.fadeInWithDuration(0.0)))
        nowNode.runAction(SKAction.waitForDuration(1.0).followedBy(SKAction.fadeInWithDuration(0.0)))
        
        self.runAction(SKAction.waitForDuration(2.0).followedBy(SKAction.runBlock{[weak self] in self!.raise(CutSceneNotifications.TheEndShown)}))
    }
    
    func setupNextButton() {
        nextButton.action = Callback(self, OutroScene.gotoLastLevel)
        nextButton.runAction(SKAction.fadeInWithDuration(0.5))
    }
    
    
    var handlingScene = false
    func gotoLastLevel() {
        if handlingScene { return }
        handlingScene = true
        let settings = GameSettings()
        settings.outroSeen = true
        settings.save()
        let scene = GameScene(level: LevelParser.parse(GameLevelData.shared.chapters.last!.levels.last!), context: self.context)
        navigation.displayGameScene(scene)
    }
}