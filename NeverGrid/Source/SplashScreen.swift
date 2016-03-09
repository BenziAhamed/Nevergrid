//
//  SplashScreen.swift
//  NeverGrid
//
//  Created by Benzi on 07/10/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SplashScreen: NavigatingScene {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init () {
        super.init(context:NavigationContext())
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setBackgroundImage("background_splash")
        
        let logo = SKSpriteNode(imageNamed: "folded_paper")
        logo.size = logo.size.scale(factor2(forPhone: 1.0, forPhone3x: 1.0, forPad: 2.0))
        logo.position = frame.mid()
        worldNode.addChild(logo)
        
        
        let onPreloadComplete = SKAction.waitForDuration(1.0)
            .followedBy(SKAction.runBlock {
                [weak self] in
                
                let gameSettings = GameSettings()
                if gameSettings.introSeen {
                    self!.navigation.displayMainMenu()
                }
                else {
                    self!.navigation.displayIntro()
                }
        })
        
        SpriteManager.Shared.preload {
            [weak self] in
            self!.runAction(onPreloadComplete)
        }
    }
}

