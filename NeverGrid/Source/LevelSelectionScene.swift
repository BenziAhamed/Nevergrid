//
//  LevelSelectionScene2.swift
//  NeverGrid
//
//  Created by Benzi on 25/11/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class LevelSelectionScene : NavigatingScene {
    
    var levelSelected = false
    var gameTimer = GameTimer()
    var dragNode:DraggableNode!
    var chapterNameNode:SKLabelNode!
    var constraintCalculator = ContentCenteredHorizontalClipConstraintCalculator()
    //var chapterSpriteNode:ChapterSpriteNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(context:NavigationContext) {
        super.init(context:context)
    }

    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
    }
    
    func initializeScene(onCompletion:TargetAction) {
        gcd.global.async { self.initializeSceneAsync(onCompletion) }
    }
    
    private func initializeSceneAsync(onCompletion:TargetAction) {
        createScene()
        setupHud()
        #if DEBUG
            setupReset()
        #endif
        onCompletion.performAction()
    }
    
    func createScene() {
        self.setBackgroundImage("background_levels")
        
        
        // create chapter nodes
        let chapterNodes = SKNode()
        var position = CGPointZero
        let layout = GridLayoutEngine(gridSize: FactoredSizes.LevelSelectionScene.gridSize)
        let pendingLevel = LevelProgressSystem.getNextLevelItem()!
        
        for (index,chapter) in GameLevelData.shared.chapters.enumerate() {
            let chapterNode = ChapterGridNode(chapter, layout: layout, pendingLevel:pendingLevel)
            let width = chapterNode.calculateAccumulatedFrame().size.width
            
            
            // correct the first chapter's grid to align with Y axis
            // and centre the whole thing to screen
            if index == 0 {
                let h = chapterNode.calculateAccumulatedFrame().size.height
                //position = CGPointMake(0, (self.frame.height - h)/2.0)
                position = CGPointMake(0, self.frame.midY)
                position = position.offset(dx: width/2.0, dy: 0.0)
            }
            
            chapterNode.position = position
            chapterNodes.addChild(chapterNode)
            
            position = position.offset(dx: width, dy: 0)
            position = position.offset(dx: 2.0 * FactoredSizes.LevelSelectionScene.spaceBetweenChapterNodes, dy: 0)
        }
        
        // make the levels draggable
        dragNode = DraggableNode(node:chapterNodes)
        dragNode.dragConstraint = DraggableNode.DragConstraint.Horizontal
        dragNode.constrainX = constraintCalculator.calculate(frame: self.frame, node: dragNode)
        dragNode.onContainedNodeTouched = Callback(self, LevelSelectionScene.onLevelSelected)

        // add chapter nodes to our world scene
        self.worldNode.addChild(dragNode)
        
        
        // center next logical chapter to play
        var nextLevelToPlay = context.selectedLevel
        if nextLevelToPlay == nil {
            updateContextWithNextLevelItem()
            nextLevelToPlay = context.selectedLevel
        } else {
            if nextLevelToPlay!.isCompleted {
                nextLevelToPlay = LevelProgressSystem.getNextLevelItemInSequence(nextLevelToPlay!)
            }
        }
        var chapterToCentre = nextLevelToPlay!.chapter!
        
        // since we want our point of interest to be centered on the screen
        // we need to calculate the offset from the screen mid to logical zero location of the dragged node
        // we use this offset to correct the final location that we need to set to the moveTo()
        // function of the draggable node
        let offsetToMiddleOfScreen = self.frame.mid().subtract(dragNode.translateLogicalToWorld(CGPointZero))
        let moveOffsetForInitialPosition = CGPointMake(factor(forPhone: -1.0, forPad: -2.0), 0.0)
        
        for (index, chapterNode) in (dragNode.draggedNode.children as! [ChapterGridNode]).enumerate() {
            if chapterNode.chapter.name == chapterToCentre.name {
                let chapterNodePosition = chapterNode.calculateAccumulatedFrame().mid().subtract(offsetToMiddleOfScreen)
                dragNode.moveTo(chapterNodePosition.add(moveOffsetForInitialPosition), duration: 0.0)
                dragNode.moveTo(chapterNodePosition)
                break
            }
        }
        
//        chapterSpriteNode = ChapterSpriteNode(chapter: chapterToCentre)
//        chapterSpriteNode.position = CGPointMake(frame.maxX, 0.0)
//        self.addChild(chapterSpriteNode)
//        
//        chapterSpriteNode.switchTo(chapterToCentre)
    }
    
    func updateContextWithNextLevelItem() {
        let level = LevelProgressSystem.getNextLevelItem()!
        context.selectedLevel = level
        context.selectedChapter = level.chapter
    }
    
    func onLevelSelected() {
        if levelSelected { return }
        if let node = NodeHelper<LevelGridNode>.matchSelfOrParent(dragNode.lastTouchedNode!) {
            #if DEBUG
                // in debug mode, we can play any level
                levelSelected = true
                node.select()
                loadLevel(node)
            #else
                levelSelected = node.select()
                if levelSelected {
                    loadLevel(node)
                }
            #endif
        }
    }
    
    func loadLevel(node:LevelGridNode) {
        context.selectedChapter = node.level.chapter
        context.selectedLevel = node.level
        let gameScene = GameScene(level: LevelParser.parse(node.level), context: self.context)
        navigation.displayGameScene(gameScene)
    }
    
    override func update(currentTime: NSTimeInterval) {
        gameTimer.advance(false)
        if let dragger = dragNode {
            dragger.update(gameTimer.gametime_elapsed)
            
            if dragger.inMotion {
                let frameMidInDraggedNode = dragger.convertPoint(self.frame.mid(), toNode: dragger.draggedNode)
                for chapterNode in dragger.draggedNode.children as! [ChapterGridNode] {
                    let frame = chapterNode.calculateAccumulatedFrame()
                    if frame.minX <= frameMidInDraggedNode.x && frameMidInDraggedNode.x <= frame.maxX {
                        if chapterNameNode.text != chapterNode.chapter.displayName {
                            chapterNameNode.text = chapterNode.chapter.displayName
                            chapterNode.showTags()
                            //chapterSpriteNode.switchTo(chapterNode.chapter)
                        }
                        break
                    }
                }
            }
        }
    }
    

    // MARK: Home button
    
    func setupHud() {
        let home = textSprite("home_level")
        let homeButton = WobbleButton(node: home, action: Callback(self,LevelSelectionScene.goToHomeScreen))
        let targetPosition = CGPointMake(home.frame.width, home.frame.height)
        homeButton.position  = targetPosition.offset(dx: 0.0, dy: -2.0*home.frame.height)
        hudNode.addChild(homeButton)
        homeButton.runAction(
            SKAction.moveTo(targetPosition, duration: 0.2)
        )
        
        // title
        chapterNameNode = SKLabelNode(fontNamed: FactoredSizes.defaultFont)
        chapterNameNode.color = UIColor.whiteColor()
        chapterNameNode.fontSize = FontSize.ChapterNameSize
        chapterNameNode.position = CGPointMake(self.frame.midX, targetPosition.y)
        chapterNameNode.text = "Chapter"
        chapterNameNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        hudNode.addChild(chapterNameNode)
    }
    
    func goToHomeScreen() {
        self.navigation.displayMainMenu()
    }
    
    #if DEBUG
    
    // MARK: Reset button
    
    func setupReset() {
        let resetNode = TextNode()
        resetNode.text = "reset!"
        resetNode.enableShadow = false
        resetNode.fontSize = 12.0
        resetNode.fontColor = UIColor.whiteColor()
        resetNode.render()
        resetNode.position = CGPointMake(frame.midX, 5.0)

        
        let resetNodeInteractive = TouchableNode(node: resetNode)
        resetNodeInteractive.onTouchBegan = Callback(self, LevelSelectionScene.resetGame)
        
        hudNode.addChild(resetNodeInteractive)
    }
    
    func resetGame() {
        LevelProgressSystem.reset()
        let context = NavigationContext()
        context.navigationTarget = NavigationTarget.LevelScreen
        navigation.displayLevelScene(LevelSelectionScene(context: context))
    }
    
    #endif
    

    // MARK: Force dragging
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dragNode.touchesBegan(touches, withEvent: event)
    }
    

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dragNode.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dragNode.touchesEnded(touches, withEvent: event)
    }
    
}

//class ChapterSpriteNode : SKSpriteNode {
//
//    required init?(coder aDecoder:NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    init(chapter:ChapterItem) {
//        let texture = ChapterSpriteNode.getTexture(chapter)
//        super.init(texture: texture, color: nil, size: texture.size())
//        anchorPoint = CGPointMake(1.0,0.0)
//    }
//    
////    class func getTexture(chapter:ChapterItem) -> SKTexture {
////        let name = chapter.displayName.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
////        return SpriteManager.Shared.chapter.texture(name)
////    }
//    
//    func switchTo(chapter:ChapterItem) {
//        
//        let texture = ChapterSpriteNode.getTexture(chapter)
//        
////        let hidePosition = CGPointMake(position.x, -frame.height)
////        let displayPosition = CGPointMake(position.x, 0.0)
////        let switchAction =
////            SKAction.moveTo(hidePosition, duration: 0.3)
////            .followedBy(SKAction.animateWithTextures([texture], timePerFrame: 0.0, resize: true, restore: false))
////            .followedBy(SKAction.moveTo(displayPosition, duration: 0.3))
////        self.removeAllActions()
//        
//        let switchAction = SKAction.animateWithTextures([texture], timePerFrame: 0.0, resize: true, restore: false)
//        self.runAction(switchAction)
//    }
//
//}


class ChapterGridNode : SKNode {
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }

    let gridSize:CGFloat = FactoredSizes.LevelSelectionScene.gridSize

    var chapter:ChapterItem! = nil
    
    init(_ chapter:ChapterItem, layout:GridLayoutEngine, pendingLevel:LevelItem) {
        
        self.chapter = chapter
        super.init()
        
        let positions = layout.calculatePositions(chapter)
        for (index,level) in chapter.levels.enumerate() {
            let node = LevelGridNode(level, isPending:level.number == pendingLevel.number)
            node.position = positions[index]
            self.addChild(node)
        }
    }
    
    
    var tagsShown = false
    func showTags() {
        if tagsShown { return }
        tagsShown = true
        var duration:NSTimeInterval = 0.3
        for node in self.children as! [LevelGridNode] {
            node.showTag(duration)
            duration += 0.05
        }
    }
}

class GridLayoutEngine {
    let gridSize:CGFloat
    
    static let grid_4x4:[(CGFloat,CGFloat)] = [
        (-1.5, 1.5), // 0
        (-0.5, 1.5), // 1
        ( 0.5, 1.5), // 2
        ( 1.5, 1.5), // 3
        
        (-1.5, 0.5), // 4
        (-0.5, 0.5), // 5
        ( 0.5, 0.5), // 6
        ( 1.5, 0.5), // 7
        
        (-1.5,-0.5), // 8
        (-0.5,-0.5), // 9
        ( 0.5,-0.5), // 10
        ( 1.5,-0.5), // 11
        
        (-1.5,-1.5), // 12
        (-0.5,-1.5), // 13
        ( 0.5,-1.5), // 14
        ( 1.5,-1.5)  // 15
    ]
    
    let positions4x4:[CGPoint]!
    let positions1x1:[CGPoint]!
    
    init(gridSize:CGFloat) {
        self.gridSize = gridSize
        self.positions4x4 = GridLayoutEngine.calculateGrid4x4(gridSize)
        self.positions1x1 = [CGPointZero]
    }
    
    class func calculateGrid4x4(gridSize:CGFloat) -> [CGPoint] {
        var points = [CGPoint]()
        for (x,y) in GridLayoutEngine.grid_4x4 {
            points.append(CGPointMake(x,y).multiply(CGPointMake(1.6, 1.1)).multiply(gridSize))
        }
        return points
    }
    
    func calculatePositions(chapter:ChapterItem) -> [CGPoint] {
        if chapter.levels.count == 1 {
            return positions1x1
        }
        return positions4x4
    }
}

class LevelGridNode : SKNode {
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }

    var level:LevelItem! = nil
    var isPending:Bool! = false
    private var tag:SKSpriteNode! = nil
    
    init(_ level:LevelItem, isPending:Bool = false) {
        self.level = level
        self.isPending = isPending
        super.init()
        
        let base = gridSprite("level_cell")
        base.size = CGSizeMake(FactoredSizes.LevelSelectionScene.gridSize, FactoredSizes.LevelSelectionScene.gridSize)
        self.addChild(base)
        
        let number = SKLabelNode(fontNamed: FactoredSizes.numberFont)
        number.text = "\(level.number)"
        number.fontColor = UIColor.blackColor()
        number.fontSize = FontSize.LevelNumberSize
        number.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        number.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        base.addChild(number)
    }
    
    func createTag() {
        
        let base = self.children[0] as! SKSpriteNode
        
        tag = gridSprite(
            isPending == true ? "cell_tag_pending" :
                (level.isCompleted ? "cell_tag_complete" : "cell_tag_incomplete")
        )
        tag.size = base.size
        tag.position = CGPointMake(
            FactoredSizes.LevelSelectionScene.gridSize/4.0,
            -FactoredSizes.LevelSelectionScene.gridSize/4.0
        )
        tag.setScale(0.0)
        tag.zPosition = 100.0
        base.addChild(tag)
        
        
        if isPending == true {
            let wobble = SKAction.repeatActionForever(
                SKAction.waitForDuration(10)
                    .followedBy(SKAction.wobble())
            )
            self.runAction(wobble)
        }
    }
    
    func showTag(duration:NSTimeInterval) {
        
        createTag()
        
        let angle = (unitRandom() > 0.5 ? 1.0 : -1.0) * unitRandom() * M_PI_8
        tag.runAction(
            SKAction.waitForDuration(duration)
            .followedBy(
                SKAction.scaleTo(1.2, duration: 0.4)
                .alongside(SKAction.rotateToAngle(angle, duration: 0.4))
            )
            .followedBy(SKAction.scaleTo(1.0, duration: 0.1))
        )
    }
    
    func select() -> Bool {
        
        if level.isCompleted || isPending == true { //|| level.number == GameLevelData.shared.totalLevels {
            tag.runAction(SKAction.scaleTo(1.5, duration: 0.1))
            if GameSettings().soundEnabled {
                self.runAction(ActionFactory.sharedInstance.playMenuSelection)
            }
            return true
        } else {
            let action =
                SKAction.scaleTo(1.5, duration: 0.1)
                .followedBy(SKAction.rotateToAngle(-1.0*tag.zRotation, duration: 0.1))
                .followedBy(SKAction.rotateToAngle(tag.zRotation, duration: 0.1))
                .followedBy(SKAction.rotateToAngle(-1.0*tag.zRotation, duration: 0.1))
                .followedBy(SKAction.rotateToAngle(tag.zRotation, duration: 0.1))
                .followedBy(SKAction.scaleTo(1.0, duration: 0.1))
            tag.runAction(action)
            if GameSettings().soundEnabled {
                self.runAction(ActionFactory.sharedInstance.playNoMove)
            }
            return false
        }
    }
}

