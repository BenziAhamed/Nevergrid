//
//  NavigatingScene.swift
//  gettingthere
//
//  Created by Benzi on 23/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import UIKit
import SpriteKit

enum NavigationTarget {
    case MainMenu
    case LevelScreen
    case GameScreen
}

class NavigationContext {
    var navigationTarget = NavigationTarget.MainMenu
    var selectedChapter:ChapterItem? = nil
    var selectedLevel:LevelItem? = nil
    var completedLevelBeingReplayed = false
    
    func clone() -> NavigationContext {
        let clone = NavigationContext()
        clone.navigationTarget = self.navigationTarget
        clone.selectedChapter = self.selectedChapter
        clone.selectedLevel = self.selectedLevel
        clone.completedLevelBeingReplayed = self.completedLevelBeingReplayed
        return clone
    }
}



class NavigatingScene: SKScene {
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

    var hudNode:SKNode!
    var titleNode:TextNode!
    var backgroundNode:SKNode!
    var worldNode:SKNode!

    var navigation = NavigationHandler()
    var context:NavigationContext!
    
    init(context:NavigationContext) {
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        
        let h = min(width, height)
        let w = max(width, height)
        
        super.init(size: CGSizeMake(w, h))

        self.context = context
        self.scaleMode = SKSceneScaleMode.ResizeFill
        
        hudNode = SKNode()
        hudNode.zPosition = EntityFactory.EntityZIndex.Hud
        self.addChild(hudNode)

        
        backgroundNode = SKNode()
        self.addChild(backgroundNode)
        
        
        worldNode = SKNode()
        self.addChild(worldNode)
    }
    
    override func didMoveToView(view: SKView) {
        navigation.view = view
    }
    
    override func willMoveFromView(view: SKView) {
        removeAllActions()
        super.willMoveFromView(view)
    }
    
    func setBackgroundImage(image:String, useAspectScaling:Bool = false) {
        let backgroundSprite = SKSpriteNode(imageNamed: image)
        backgroundSprite.size = useAspectScaling ?
            backgroundSprite.size.aspectFillTo(frame.size)
            : frame.size
        backgroundSprite.position = CGPointMake(self.frame.midX, self.frame.midY)
        backgroundSprite.blendMode = SKBlendMode.Replace
        self.backgroundNode.addChild(backgroundSprite)
    }
    
    func createRecognizer(inout target:UISwipeGestureRecognizer!, direction:UISwipeGestureRecognizerDirection, delegate:UIGestureRecognizerDelegate) {
        target = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        target.direction = direction
        target.delegate = delegate
        self.view!.addGestureRecognizer(target)
    }
    
    
    /// sets the title for this scene
    func setTitle(title:String, permanent:Bool=true) {
        let textBase = self.frame.height - FactoredSizes.NavigatingScene.textBaseOffset
        
        titleNode = TextNode()
        titleNode.text = title
        titleNode.fontSize = FontSize.Title
        titleNode.position = CGPointMake(self.frame.width/2, self.frame.height+100)
        titleNode.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        titleNode.shadowBlur = 30.0
        titleNode.render()
        
        let destination = CGPointMake(self.frame.width/2, textBase)
        
        if !permanent {
            // move in and disappear after a while
            // if not permanent
            // e.g. tutorial tips
            titleNode.runAction(SKAction.sequence([
                SKAction.moveTo(destination, duration: 0.3),
                SKAction.waitForDuration(30),
                SKAction.fadeAlphaTo(0, duration: 3)
                ]))
        } else {
            // move in and just stay there
            titleNode.runAction(SKAction.moveTo(destination, duration: 0.3))
        }
        
        titleNode.zPosition = EntityFactory.EntityZIndex.Hud
        self.hudNode.addChild(titleNode)
    }
    
    func labelNode(text text:String, size:CGFloat, position: CGPoint, alpha:CGFloat = 1.0, fontName:String = FactoredSizes.defaultFont) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: fontName)
        node.text = text
        node.fontColor = UIColor.whiteColor()
        node.fontSize = size
        node.position = position
        node.alpha = alpha
        return node
    }
}
