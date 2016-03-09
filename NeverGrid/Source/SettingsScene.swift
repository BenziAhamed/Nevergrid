//
//  SettingsScene.swift
//  NeverGrid
//
//  Created by Benzi on 09/03/15.
//  Copyright (c) 2015 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SettingsScene : NavigatingScene {
    
    var musicCheckbox:CheckboxNode!
    var soundCheckbox:CheckboxNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init () {
        super.init(context:NavigationContext())
    }

    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setBackgroundImage("background_settings")
        
        // home button
        let home = textSprite("home_level")
        let homeButton = WobbleButton(node: home, action: Callback(self, SettingsScene.goToHome))
        homeButton.position = CGPointMake(
            home.frame.width,
            home.frame.height
        )
        worldNode.addChild(homeButton)
        
        // music effects
        musicCheckbox = CheckboxNode(
            text: "MUSIC",
            active: GameMusic.sharedInstance.musicEnabled
        )
        musicCheckbox.onSelected = Callback(self, SettingsScene.toggleMusic)
        worldNode.addChild(musicCheckbox)
        
        
        // sound effects
        soundCheckbox = CheckboxNode(
            text: "SOUND EFFECTS",
            active: GameSettings().soundEnabled
        )
        soundCheckbox.onSelected = Callback(self, SettingsScene.toggleSounds)
        worldNode.addChild(soundCheckbox)
        
        
        // position the checkboxes
        let musicFrame = musicCheckbox.containedNode.calculateAccumulatedFrame()
        let soundFrame = soundCheckbox.containedNode.calculateAccumulatedFrame()
        let startX = (frame.width - soundFrame.width)/2.0
        musicCheckbox.position = CGPointMake(startX, 0.66 * frame.height)
        soundCheckbox.position = musicCheckbox.position.offset(dx: 0.0, dy: -2.0 * soundFrame.height)
        
    }
    
    
    func goToHome() {
        self.navigation.displayMainMenuWithReveal(SKTransitionDirection.Right)
    }
    
    
    func toggleMusic() {
        GameMusic.sharedInstance.toggle()
        musicCheckbox.toggle()
    }
    
    func toggleSounds() {
        let settings = GameSettings()
        settings.soundEnabled = (settings.soundEnabled ? false : true)
        settings.save()
        soundCheckbox.toggle()
    }
    
}


class CheckboxNode : TouchableNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var onSelected:TargetAction?
    var imageNode:SKSpriteNode!
    var textNode:SKLabelNode!
    var active:Bool!

    init(text:String, active:Bool) {
        imageNode = textSprite(active ? "checkbox_on" : "checkbox_off")
        textNode = SKLabelNode(fontNamed: "Luckiest Guy")
        self.active = active
        super.init(node: imageNode)
        
        
        textNode.text = text
        textNode.fontSize = factor2(forPhone: 40.0, forPhone3x: 42.0, forPad: 75.0)
        textNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        textNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        textNode.position = CGPointMake(0.7 * imageNode.frame.width, 0.0)
        imageNode.addChild(textNode)
        
        super.onTouchBegan = Callback(self, CheckboxNode.onTouchBegan)
        super.onTouchEnded = Callback(self, CheckboxNode.onTouchEnded)
    }
    
    
    func toggle() {
        active = (active! ? false : true)
        imageNode.texture = SpriteManager.Shared.text.texture(active! ? "checkbox_on" : "checkbox_off")
    }
    
    
    func onTouchBegan() {
        if GameSettings().soundEnabled {
            self.runAction(ActionFactory.sharedInstance.playMenuSelection)
        }
    }
    
    func onTouchEnded() {
        if let a = onSelected {
            a.performAction()
        }
    }
}

