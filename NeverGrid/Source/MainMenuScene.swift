//
//  MainMenuScene.swift
//  gettingthere
//
//  Created by Benzi on 23/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuScene: NavigatingScene {
    
    var playWobbleButton:WobbleButton!
    var levelsWobbleButton:WobbleButton!
    
    var animationSim:Simulation!
    var timer:GameTimer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init () {
        super.init(context:NavigationContext())
        
        animationSim = Simulation()
        timer = GameTimer()
        
        animationSim.every(10.0).perform(Callback(self, MainMenuScene.bouncePlayButton))
        animationSim.start()
    }

    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        setBackgroundImage("background_mainmenu", useAspectScaling:true)
        
        //renderClouds(self)
        
        let title = textSprite("nevergrid")
        let player = textSprite("player")

        let titlePosition = CGPointMake(frame.midX, 0.66*frame.height)
        let playerPosition = titlePosition.offset(
            dx: (-title.frame.width/2.0-player.frame.width/2.0) + 0.2*player.frame.width,
            dy: -title.frame.height/2.0 + player.frame.height/2.0
        )
        
        title.position = titlePosition
        title.alpha = 0.0
        title.setScale(0.1)
        worldNode.addChild(title)

        player.position = playerPosition
        player.zRotation = degToRad(8.0)
        player.runAction(SKAction.repeatActionForever(
                SKAction.scaleTo(0.8, duration: 2.0)
                .followedBy(SKAction.waitForDuration(0.5))
                .followedBy(SKAction.scaleTo(1.0, duration: 2.0))
            ))
        worldNode.addChild(player)
        
        
        title.runAction(
            (   SKAction.scaleTo(0.1, duration: 0.0)
                .alongside(SKAction.fadeAlphaTo(0.1, duration: 0.0))
            ).followedBy(
                SKAction.scaleTo(1.0, duration: 0.3)
                .alongside(SKAction.fadeAlphaTo(1.0, duration: 0.3))
            )
            .followedBy(SKAction.wobble())
        )

        
        // play button
        let play = textSprite("play")
        let playButtonPosition = CGPointMake(self.frame.midX, play.frame.height)
        playWobbleButton = WobbleButton(node: play, action: Callback(self, MainMenuScene.playButtonAction))
        playWobbleButton.position = playButtonPosition.offset(dx: 0.0, dy: -2.0*play.frame.height)
        playWobbleButton.runAction(
            SKAction.moveTo(playButtonPosition, duration: 0.2)
            .followedBy(ActionFactory.sharedInstance.bounce)
        )
        worldNode.addChild(playWobbleButton)
        
        // levels button
        let levels = textSprite("levels")
        let levelsButtonPosition = CGPointMake(self.frame.maxX - levels.frame.width - 10.0, playButtonPosition.y)
        levelsWobbleButton = WobbleButton(node: levels, action: Callback(self, MainMenuScene.levelsButtonAction))
        levelsWobbleButton.position = levelsButtonPosition.offset(dx: 0.0, dy: -2.0*levels.frame.height)
        levelsWobbleButton.runAction(
            SKAction.waitForDuration(0.3)
            .followedBy(SKAction.moveTo(levelsButtonPosition, duration: 0.2))
        )
        worldNode.addChild(levelsWobbleButton)
        
        
        // info button
        let info = textSprite("info")
        let infoButton = WobbleButton(node: info, action: Callback(self, MainMenuScene.infoButtonAction))
        infoButton.position = CGPointMake(info.frame.width, frame.height-info.frame.height)
        infoButton.alpha = 0.0
        infoButton.runAction(SKAction.fadeInWithDuration(1.0))
        worldNode.addChild(infoButton)
        
        
        // settings button
        let settings = textSprite("settings")
        let settingsButton = WobbleButton(node: settings, action: Callback(self, MainMenuScene.settingsButtonAction))
        settingsButton.position = CGPointMake(frame.width-settings.frame.width, frame.height-settings.frame.height)
        settingsButton.alpha = 0.0
        settingsButton.runAction(SKAction.fadeInWithDuration(1.0))
        worldNode.addChild(settingsButton)
        
        GameMusic.sharedInstance.setup()
    }
    
    
    func hideButtons() {
        playWobbleButton.runAction(SKAction.moveTo(playWobbleButton.position.offset(dx: 0.0, dy: -2.0*playWobbleButton.containedNode.frame.height), duration: 0.2))
        levelsWobbleButton.runAction(SKAction.moveTo(levelsWobbleButton.position.offset(dx: 0.0, dy: -2.0*levelsWobbleButton.containedNode.frame.height), duration: 0.2))
    }
    
    
    func playButtonAction() {
        
        hideButtons()
        let context = NavigationContext()
        context.navigationTarget = NavigationTarget.GameScreen
        let gameScene = GameScene(level: LevelProgressSystem.getNextLevel(), context:context)
        navigation.displayGameScene(gameScene)
    }
    
    func levelsButtonAction() {
        
        hideButtons()
        let context = NavigationContext()
        context.navigationTarget = NavigationTarget.LevelScreen
        
        //navigation.displayLevelScene2(context)
        
        let levelScene = LevelSelectionScene(context: context)
        navigation.displayLevelScene(levelScene, fromMainMenu: true)
    }
    
    
    func infoButtonAction() {
        self.navigation.displayCreditsScene()
    }
    
    func settingsButtonAction() {
        self.navigation.displaySettingsScene()
    }
    
    func bouncePlayButton() {
        playWobbleButton.runAction(ActionFactory.sharedInstance.bounce)
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        timer.advance(false)
        animationSim.update(timer.gametime_elapsed)
    }
}