//
//  NavigationSystem.swift
//  gettingthere
//
//  Created by Benzi on 23/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class NavigationHandler {
    
    enum State {
        case Ready
        case Loading
    }
    
    weak var view:SKView?

    weak var gameScene:GameScene? = nil
    weak var levelScene:LevelSelectionScene? = nil
    var state = State.Ready
    
    init() {}
    
    
    func displayIntro() {
        let transition = SKTransition.crossFadeWithDuration(0.5)
        transition.pausesOutgoingScene = false
        view!.presentScene(IntroScene(), transition: transition)
    }
    
    func displayOutro(context:NavigationContext) {
        let transition = SKTransition.crossFadeWithDuration(0.5)
        transition.pausesOutgoingScene = false
        view!.presentScene(OutroScene(context: context), transition: transition)
    }
    
    func displayMainMenu() {
        //direction:SKTransitionDirection = SKTransitionDirection.Down
        //let transition = SKTransition.moveInWithDirection(direction, duration: 0.5)
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
        let mainMenu = MainMenuScene()
        view!.presentScene(mainMenu, transition: transition)
    }
    
    func displayMainMenuWithReveal(direction:SKTransitionDirection = SKTransitionDirection.Down) {
        let transition = SKTransition.revealWithDirection(direction, duration: 0.5)
        let mainMenu = MainMenuScene()
        view!.presentScene(mainMenu, transition: transition)
    }
    
    func displayCreditsScene() {
        let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Left, duration: 0.5)
        let scene = CreditsScene()
        view!.presentScene(scene, transition: transition)
    }
    
    func displaySettingsScene() {
        let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Right, duration: 0.5)
        let scene = SettingsScene()
        view!.presentScene(scene, transition: transition)
    }
    
    func displayGameOverScene(scene:SKScene) {
        //let transition = SKTransition.crossFadeWithDuration(0.5)
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
        //let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Up, duration: 0.5)
        transition.pausesOutgoingScene = false
        view!.presentScene(scene, transition: transition)
    }
    
    func goToLevelScene(context:NavigationContext) {
        displayLevelScene(LevelSelectionScene(context: context))
    }
    
    

    // MARK: level scene
    
    var fromMainMenu = false
    func displayLevelScene(scene:LevelSelectionScene, fromMainMenu:Bool = false) {
        if state == .Loading { return }
        state = .Loading
        levelScene = scene
        self.fromMainMenu = fromMainMenu
        levelScene!.initializeScene(Callback(self, NavigationHandler.displayLevelScene))
    }
    
    private func displayLevelScene() {
        let transition = SKTransition.moveInWithDirection(
            fromMainMenu ? SKTransitionDirection.Up : SKTransitionDirection.Down,
            duration: 0.5
        )
        transition.pausesOutgoingScene = false
        view!.presentScene(levelScene!, transition: transition)
        levelScene = nil
        state = .Ready
    }
    
    // MARK: game scene
    
    func reloadGameScene(context:NavigationContext, levelItem:LevelItem) {
        //gameScene = GameScene(level: LevelParser.parse(levelItem), context: context.clone())
        //displayGameScene(gameScene!)
        
        
        // force load now
        let scene = GameScene(level: LevelParser.parse(levelItem), context: context)
        displayGameScene(scene)
    }
    
//    func displayGameScene(scene:GameScene) {
//        if state == .Loading { return }
//        state = .Loading
//        let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Up, duration: 0.5)
//        transition.pausesOutgoingScene = false
//        view!.presentScene(scene, transition: transition)
//    }
    
    func displayGameScene(scene:GameScene) {
        
        if scene.level.info.number == GameLevelData.shared.totalLevels {
            if !GameSettings().outroSeen {
                displayOutro(scene.context)
                return
            }
        }
        
        
        if state == .Loading { return }
        state = .Loading
        gameScene = scene
        gameScene!.createEntities(Callback(self, NavigationHandler.displayGameScene))
    }
    
    func displayGameScene() {
        let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Up, duration: 0.5)
        transition.pausesOutgoingScene = false
        view!.presentScene(gameScene!, transition: transition)
        gameScene = nil
        state = .Ready
    }
}