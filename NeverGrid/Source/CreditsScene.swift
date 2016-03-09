//
//  CreditsScene.swift
//  NeverGrid
//
//  Created by Benzi on 05/03/15.
//  Copyright (c) 2015 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class CreditsScene : NavigatingScene {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init () {
        super.init(context:NavigationContext())
    }

    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setBackgroundImage("background_credits")
        
        let logo = textSprite("credits")
        logo.position = frame.mid() //CGPointMake(frame.midX, 0.66 * frame.height)
        worldNode.addChild(logo)


        // home button
        let home = textSprite("home_level")
        let homeButton = WobbleButton(node: home, action: Callback(self, CreditsScene.goToHome))
        homeButton.position = CGPointMake(
            self.frame.width - home.frame.width,
            home.frame.height
        )
        worldNode.addChild(homeButton)
        
        
        // twitter button
        let twitter = textSprite("twitter")
        let twitterButton = WobbleButton(node: twitter, action: Callback(self, CreditsScene.showTwitter))
        twitterButton.position = CGPointMake(logo.position.x, logo.position.y-logo.frame.height/2.0-twitter.frame.height)
        worldNode.addChild(twitterButton)
    }
    
    func goToHome() {
        self.navigation.displayMainMenuWithReveal(SKTransitionDirection.Left)
    }
    
    func showTwitter() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/benziahamed")!)
    }
    
}