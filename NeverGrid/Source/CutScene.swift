//
//  CutScene.swift
//  NeverGrid
//
//  Created by Benzi on 15/03/15.
//  Copyright (c) 2015 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

struct CutSceneNotifications {
    static let SceneCreated = "SceneCreated"
    static let SceneVisible = "SceneVisible"
    static let StarsFallen = "StarsFallen"
    static let BackgroundMoved = "BackgroundMoveDone"
    static let PlayerEntered = "PlayerEntered"
    static let MessageShown = "MessageShown"
    static let TheEndShown = "TheEndShown"
}

class CutScene : SKScene {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    var hudNode:SKNode!
    var backgroundNode:SKNode!
    var worldNode:SKNode!
    var navigation:NavigationHandler!
    
    override init() {
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        
        let h = min(width, height)
        let w = max(width, height)
        
        super.init(size: CGSizeMake(w, h))
        
        self.scaleMode = SKSceneScaleMode.ResizeFill
        
        hudNode = SKNode()
        hudNode.zPosition = EntityFactory.EntityZIndex.Hud
        self.addChild(hudNode)
        
        
        backgroundNode = SKNode()
        self.addChild(backgroundNode)
        
        
        worldNode = SKNode()
        self.addChild(worldNode)
        
        self.navigation = NavigationHandler()
    }
    
    override func didMoveToView(view: SKView) {
        self.navigation.view = view
    }
    
    
    func on(name:String, _ callback:TargetAction) {
        eventHandlers[name] = callback
    }
    
    func raise(name:String) {
        if let handler = eventHandlers[name] {
            #if DEGUG
                println("CutScene: running event \(name)")
            #endif
            handler.performAction()
        }
    }
    
    var eventHandlers = [String:TargetAction]()
}
