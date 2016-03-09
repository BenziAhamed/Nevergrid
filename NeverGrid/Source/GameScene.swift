//
//  GameScene.swift
//  gettingthere
//
//  Created by Benzi on 20/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import SpriteKit


class EventForwarder : EventHandler {
    weak var scene:GameScene?
    
    init(scene:GameScene) {
        self.scene = scene
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        scene?.handleEvent(event, data)
    }
}

class GameScene: NavigatingScene {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var gameEventForwarder:EventForwarder!
    var game:GameSystem!
    var world:WorldMapper!
    var ignoreTouches:Bool = false
    var overlay:SKSpriteNode!
    var level:Level!
    
    var cameraNode:SKNode!
    var gridNode:SKNode!
    var entitiesNode:SKNode!
    
    var timer = GameTimer()
    
    var menuBar:MenuBar!
    var pauseGameNode:PauseGameNode!
    var gameHintsNode:GameHintsNode!
    
    var initialTouchLocation:CGPoint = CGPointZero
    
    let displayLevelName = false
    
    // ----------------------------------------------------------------
    // MARK: Init
    // ----------------------------------------------------------------
    
    init(level:Level, context:NavigationContext) {
        super.init(context:context)
        self.level = level
        initializeScene()
    }
    
    
    func initializeScene() {
        let theme = ThemeManager.defaultTheme()
        let gsOptions = GridSystemOptions()

        gsOptions.frame = self.frame
        gsOptions.preferredCellSizeInPoints = FactoredSizes.GameScene.preferredCellSizeInPoints
        gsOptions.cellExtendsInPoints = gsOptions.preferredCellSizeInPoints * theme.settings.cellExtends
        gsOptions.forcePreferredCellSize = true
        gsOptions.rows = level.rows
        gsOptions.columns = level.columns
        gsOptions.cellSpacingInPoints = theme.settings.cellSpacing
        
        
        let gs = GridSystem(options: gsOptions)
        
        cameraNode = SKNode()
        gridNode = SKNode()
        entitiesNode = SKNode()
        
        self.worldNode.addChild(gridNode)
        self.gridNode.addChild(entitiesNode)
        self.worldNode.addChild(cameraNode)
        
        self.setBackgroundImage(theme.settings.gameplayImage)
        
        world = WorldMapper(manager: EntityManager(), level: level, gs: gs, scene: self)
        world.theme = theme
        
        game = GameSystem(world)
        
        gameEventForwarder = EventForwarder(scene: self)
        world.eventBus.subscribe(GameEvent.GameOver, handler: gameEventForwarder)
        world.eventBus.subscribe(GameEvent.GameStarted, handler: gameEventForwarder)
        
        #if DEBUG
            updateLoopCounter = 0
        #endif
        
        
        // overlay
        overlay = backgroundSprite("background_darkgray")
        overlay.size = self.frame.size
        overlay.position = self.frame.mid()
        overlay.alpha = 0.0
        hudNode.addChild(overlay)
        
        pauseGameNode = PauseGameNode(gameScene: self)
        gameHintsNode = GameHintsNode(gameScene: self)
        
        
        hudNode.addChild(pauseGameNode)
        hudNode.addChild(gameHintsNode)
    }
    
    
    func createEntities(onCompletion:TargetAction) {
        gcd.global.async { self.createEntitiesAsync(onCompletion) }
    }
    
    private func createEntitiesAsync(onCompletion:TargetAction) {
        self.paused = true
        game.createEntities()
        self.paused = false
        onCompletion.performAction()
    }
    
    
    // ----------------------------------------------------------------
    // MARK: Main entry point
    // ----------------------------------------------------------------
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        game.startGame()
        world.eventBus.raise(GameEvent.SceneLoaded, data: nil)
    }
    
    
    override func willMoveFromView(view: SKView) {
        world.eventBus.raise(GameEvent.SceneUnloaded, data: nil)
        world.eventBus.reset()
        super.willMoveFromView(view)
    }
    
    
    // ----------------------------------------------------------------
    // MARK: UI stuff
    // ----------------------------------------------------------------
    
    func reloadScene() {
        navigation.reloadGameScene(self.context,levelItem: self.world.level.info)
    }
    
    func closeScene() {
        navigation.displayMainMenu()
    }
    
    func goToLevels() {
        navigation.goToLevelScene(context)
    }
    
    
    func setupDebug() {
        // debug
        let levelName = super.labelNode(
            text: world.level.info.levelKey as String,
            size: 12,
            position: CGPointMake(CGRectGetMidX(self.frame), 5),
            alpha: 0.3,
            fontName: FactoredSizes.defaultFont
        )
        self.addChild(levelName)
    }
    
    
    // ----------------------------------------------------------------
    // MARK: Game setup
    // ----------------------------------------------------------------
    
    
    func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        case GameEvent.GameOver:
            onGameOver(data as! GameOverReason)
        case GameEvent.GameStarted:
            pauseGameNode.showPauseButton()
            if gameHintsNode.hasContent {
                gameHintsNode.showHintsButton()
                if gameHintsNode.shouldLoadAtGameStart {
                    gameHintsNode.show()
                }
            }
            
        default:
            break
        }
    }
    
    // game over event handling
    // note that you can recieve multiple game over events simultaneously
    // so just handle the first such event
    func onGameOver(reason:GameOverReason) {
        //world.eventBus.unsubscribe(GameEvent.GameOver, handler: self)
        var scene:SKScene!
        if reason.won {
            // the scene to load
            scene = GameWonScene(reason: reason, levelItem:self.world.level.info,  state:world.state, context: self.context)
        } else {
            scene = GameLostScene(reason: reason, levelItem:self.world.level.info,  context: self.context)
        }
        
        // load the game over scene
        self.runAction(
            SKAction.waitForDuration(reason.won ? 1.5 : 1.0)
            .followedBy(SKAction.runBlock({ [weak self] in self!.navigation.displayGameOverScene(scene) }))
        )
    }
    
    
    // ----------------------------------------------------------------
    // MARK: Game Update
    // ----------------------------------------------------------------
    
    override func update(currentTime: CFTimeInterval) {
        
        #if DEBUG
        updateLoopCounter++
        #endif
        
        timer.advance(self.paused)
        self.game.update(timer.gametime_elapsed)
    }
    
}

extension GameScene {
    // ----------------------------------------------------------------
    // MARK: World Camera
    // ----------------------------------------------------------------
    
    override func didSimulatePhysics() {
        self.centerOnNode(self.cameraNode)
    }
    
    
    func centerOnNode(node:SKNode) {
        // NOTE camera is at 0,0 but scene anchor point is also 0,0
        // so this really does not centre on node, but ensures
        // camera is always at 0,0 which means we are moving the frame
        // reference of origin 0,0 visually
        let cameraPositionInScene = node.scene!.convertPoint(node.position, fromNode: node.parent!)
        node.parent!.position = node.parent!.position.subtract(cameraPositionInScene)
    }
}


extension GameScene {
    
    // ----------------------------------------------------------------
    // MARK: User Input
    // ----------------------------------------------------------------
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if ignoreTouches { return }
        
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        initialTouchLocation = touchLocation
    }
    
    // enables tapping to skip a turn
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if ignoreTouches { return }
        
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        let distance = initialTouchLocation.distanceTo(touchLocation)
        
        if distance < 20.0 {
            let targetFrame = frame.resize(dw:0, dh:FactoredSizes.GameFrame.TitleSpace)
            if targetFrame.contains(touchLocation) {
                world.eventBus.raise(GameEvent.UserSwipe, data: Direction.None)
            }
        }
        else {
            let swipeInput = getDirection(initialTouchLocation, end: touchLocation)
            if swipeInput != Direction.None {
                world.eventBus.raise(GameEvent.UserSwipe, data: swipeInput)
            }
        }
    }
    
    
    func getDirection(start:CGPoint, end:CGPoint) -> UInt {
        
        let distance = start.distanceTo(end)
        var angle:CGFloat = end.angleTo(start)
        if angle < 0 {
            angle = CGFloat(2.0*M_PI) + angle
        }
        angle = radToDeg(angle)
        
        //        println("distance: \(distance)")
        //        println("angle: \(angle)")
        //        println("------")
        
        var direction = Direction.None
        
        if distance > 5.0 {
            
            switch angle {
            case let x where x >= 315.0 && x <= 360.0:
                direction = Direction.Right
            case let x where x >= 0.0 && x <= 45.0:
                direction = Direction.Right
                
            case let x where x >= 45.0 && x <= 135.0:
                direction = Direction.Up
                
            case let x where x >= 135.0 && x <= 225.0:
                direction = Direction.Left
                
            case let x where x >= 225.0 && x <= 315.0:
                direction = Direction.Down
                
            default: break
            }
            
        }
        
        
        return direction
    }
}




//        if level.title == nil {
//            gsOptions.frame = self.frame
//        } else {
//            gsOptions.frame = self.frame.resize(dw:0, dh:FactoredSizes.GameFrame.TitleSpace)
//        }


//extension GameScene: UIGestureRecognizerDelegate {

// Touch recognizers
//    var swipeUp:UISwipeGestureRecognizer!
//    var swipeRight:UISwipeGestureRecognizer!
//    var swipeDown:UISwipeGestureRecognizer!
//    var swipeLeft:UISwipeGestureRecognizer!
//    var pathRecognizer:PlayerPathGestureRecognizer!

//    // ----------------------------------------------------------------
//    // MARK: User Input
//    // ----------------------------------------------------------------
//
//
////    // TODO: remove
////    func addGestureRecognizers(){
////
////        //        createRecognizer(&swipeUp, direction: UISwipeGestureRecognizerDirection.Up, delegate:self)
////        //        createRecognizer(&swipeDown, direction: UISwipeGestureRecognizerDirection.Down, delegate:self)
////        //        createRecognizer(&swipeLeft, direction: UISwipeGestureRecognizerDirection.Left, delegate:self)
////        //        createRecognizer(&swipeRight, direction: UISwipeGestureRecognizerDirection.Right, delegate:self)
////
////        // TODO: remove
////        //        pathRecognizer = PlayerPathGestureRecognizer(world: self.world, target: self, action: "handlePath:")
////        //        pathRecognizer.delegate = self
////        //        self.view.addGestureRecognizer(pathRecognizer)
////
////    }
////
////    func removeGestureRecognizers() {
////
////        //        view!.removeGestureRecognizer(swipeUp)
////        //        view!.removeGestureRecognizer(swipeDown)
////        //        view!.removeGestureRecognizer(swipeLeft)
////        //        view!.removeGestureRecognizer(swipeRight)
////        //        view.removeGestureRecognizer(pathRecognizer)
////    }
//
//
////    func handlePath(recognizer:PlayerPathGestureRecognizer) {
////        if recognizer.state == UIGestureRecognizerState.Ended {
////            // raise a path move event
////            world.eventBus.raise(GameEvent.UserPathCreated, data: recognizer.path)
////        }
////    }
//
////    // handles swipes
////    // The swipe direction values are the same as the values in the Direction struct
////    func handleSwipe(recognizer:UISwipeGestureRecognizer){
////        world.eventBus.raise(GameEvent.UserSwipe, data: recognizer.direction.toRaw())
////    }
//
//
//    //    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
//    //        // gesture recognizer should be enabled only if we are not handling
//    //        // a menu touch already
//    //        return !closeMenuItem.handlingTouch && !reloadMenuItem.handlingTouch
//    //    }
//
//}
