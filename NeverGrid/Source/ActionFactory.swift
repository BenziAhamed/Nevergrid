//
//  ActionFactory.swift
//  gettingthere
//
//  Created by Benzi on 06/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


// Provides cached actions for re-use and some
// helper methods to create specific action sequences
class ActionFactory {
    
    struct Timing {
        static let EntityMove = 0.2
    }
    
    
    // MARK: sounds
    let playCollectCoin = SKAction.playSoundFileNamed("collect_coin.wav", waitForCompletion: false)
    let playCollectItem = SKAction.playSoundFileNamed("collect_item.wav", waitForCompletion: false)
    let playPop = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let playTeleport = SKAction.playSoundFileNamed("teleport.wav", waitForCompletion: false)
    let playMenuSelection = SKAction.playSoundFileNamed("menu_selection.wav", waitForCompletion: false)
    let playCloned = SKAction.playSoundFileNamed("cloned.wav", waitForCompletion: false)
    let playDeath = SKAction.playSoundFileNamed("woosh.wav", waitForCompletion: false)
    let playRobotWakeup = SKAction.playSoundFileNamed("robot_wakeup.wav", waitForCompletion: false)
    let playThud = SKAction.playSoundFileNamed("thud.wav", waitForCompletion: false)
    let playPoink = SKAction.playSoundFileNamed("poink.wav", waitForCompletion: false)
    let playNoMove = SKAction.playSoundFileNamed("player_no_move.wav", waitForCompletion: false)
    
    // MARK: node maintenance
    let removeFromParent = SKAction.removeFromParent()
    
    
    // MARK: falling cells
    func fallingCrumpAnimation() -> SKAction {
        let wait = SKAction.waitForDuration(0.2, withRange: 0.6)
        let falloff:CGFloat = -(100.0+100*unitRandom())
        let fadeoff:NSTimeInterval = NSTimeInterval(0.5*unitRandom()+0.3)
        let action =
            wait
            .followedBy(
                SKAction.moveByX(0.0, y: falloff, duration: 2.0)
                .alongside(SKAction.fadeOutWithDuration(fadeoff))
            )
            .followedBy(SKAction.removeFromParent())
        return action
    }
    
    // MARK: bounce
    struct BounceParameters {
        static let bounce1:CGFloat = factor(forPhone: 6.0, forPad: 10.0)
        static let bounce2:CGFloat = factor(forPhone: 5.0, forPad: 6.0)
        static let bounce3:CGFloat = factor(forPhone: 2.0, forPad: 3.0)
    }
    let bounce =
        SKAction.moveByX(0.0, y: BounceParameters.bounce1, duration: 0.2)
        .followedBy(SKAction.moveByX(0.0, y: -BounceParameters.bounce1, duration: 0.1))
        .followedBy(SKAction.moveByX(0.0, y: BounceParameters.bounce2, duration: 0.2))
        .followedBy(SKAction.moveByX(0.0, y: -BounceParameters.bounce2, duration: 0.1))
        .followedBy(SKAction.moveByX(0.0, y: BounceParameters.bounce3, duration: 0.1))
        .followedBy(SKAction.moveByX(0.0, y: -BounceParameters.bounce3, duration: 0.1))
    
    // MARK: force jump
    struct JumpParameters {
        static let amount:CGFloat = factor(forPhone: 8.0, forPad: 14.0)
    }
    
    var forceJump:SKAction {
        let action = SKAction.scaleXTo(1.1, y: 0.9, duration: 0.2) // squeeze down
        .followedBy(SKAction.waitForDuration(0.1)) // wait
        .followedBy( // jump up + squeezing to make long
            SKAction.moveByX(0.0, y: JumpParameters.amount, duration: 0.2)
            .alongside(SKAction.scaleXTo(0.95, y: 1.05, duration: 0.2))
        )
        .followedBy(SKAction.waitForDuration(0.2)) // wait
        .followedBy(SKAction.moveByX(0.0, y: -JumpParameters.amount, duration: 0.1)) // just down
        .followedBy(
            GameSettings().soundEnabled ?
                SKAction.playSoundFileNamed("thud.wav", waitForCompletion: false)
            :   SKAction.waitForDuration(0.0)
        ) // impact noise
        .followedBy(SKAction.scaleXTo(1.05, y: 0.95, duration: 0.2)) // wobble back
        .followedBy(SKAction.scaleXTo(1.0, y: 1.0, duration: 0.1)) // restore size
        return action
    }
    
    //let forceJumpTwice = SKAction.repeatAction(ActionFactory.sharedInstance.forceJump, count: 2)
    
    // MARK: scale
    let scaleToLarge = SKAction.scaleTo(1.2, duration: 0.5)
    let scaleToSmall = SKAction.scaleTo(0.8, duration: 0.5)
    let scaleToZero = SKAction.scaleTo(0, duration: 0.05)
    let scaleToNormal = SKAction.scaleTo(1, duration: 0.05)
    let scaleSmallToLarge:SKAction!
    
    // MARK: temporal
    let shortDelay = SKAction.waitForDuration(0.25, withRange: 0.5)
    let delay = SKAction.waitForDuration(0.5, withRange: 0.75)
    
    
    // MARK: visibility
    let fadeIn = SKAction.fadeInWithDuration(0.2)
    let fadeOut = SKAction.fadeOutWithDuration(0.2)
    let fadeOutSlowly = SKAction.fadeOutWithDuration(0.5)
    let fadeOutInSlowly:SKAction!
    
    
    // MARK: shakes
    var shakeSlowContinuous:SKAction!
    var shakeFastContinuous:SKAction!
    let stopShaking = SKAction.rotateToAngle(0, duration: 0)
    let shakeSlowAction = SKAction.sequence([
        SKAction.rotateByAngle(M_PI_32, duration: 0.1),
        SKAction.rotateByAngle(-M_PI_32, duration: 0.1),
        SKAction.rotateByAngle(-M_PI_32, duration: 0.1),
        SKAction.rotateByAngle(M_PI_32, duration: 0.1)
    ])
    let shakeFastAction = SKAction.sequence([
        SKAction.rotateByAngle(M_PI_24, duration: 0.05),
        SKAction.rotateByAngle(-M_PI_24, duration: 0.05),
        SKAction.rotateByAngle(-M_PI_24, duration: 0.05),
        SKAction.rotateByAngle(M_PI_24, duration: 0.05)
    ])
    let shakeActionLeft = SKAction.sequence([
        SKAction.moveByX(-3, y: 0, duration: 0.1),
        SKAction.moveByX(+3, y: 0, duration: 0.1),
        SKAction.moveByX(+3, y: 0, duration: 0.07),
        SKAction.moveByX(-3, y: 0, duration: 0.07)
    ])
    let shakeActionRight = SKAction.sequence([
        SKAction.moveByX(+3, y: 0, duration: 0.1),
        SKAction.moveByX(-3, y: 0, duration: 0.1),
        SKAction.moveByX(-3, y: 0, duration: 0.07),
        SKAction.moveByX(+3, y: 0, duration: 0.07)

    ])
    let shakeActionDown = SKAction.sequence([
        SKAction.moveByX(0, y: -3, duration: 0.1),
        SKAction.moveByX(0, y: +3, duration: 0.1),
        SKAction.moveByX(0, y: +3, duration: 0.07),
        SKAction.moveByX(0, y: -3, duration: 0.07)
    ])
    let shakeActionUp = SKAction.sequence([
        SKAction.moveByX(0, y: +3, duration: 0.1),
        SKAction.moveByX(0, y: -3, duration: 0.1),
        SKAction.moveByX(0, y: -3, duration: 0.07),
        SKAction.moveByX(0, y: +3, duration: 0.07)

    ])
    let shakeActionNone = SKAction.moveByX(0, y: 0, duration: 0)
    
    init() {
        self.scaleSmallToLarge = SKAction.repeatActionForever(SKAction.sequence([scaleToSmall,scaleToLarge]))
        self.fadeOutInSlowly = SKAction.repeatActionForever(SKAction.sequence([
            SKAction.fadeAlphaTo(0.5, duration: 2),
            SKAction.fadeAlphaTo(1.0, duration: 2)
        ]))
        shakeSlowContinuous = SKAction.sequence([stopShaking, SKAction.repeatActionForever(shakeSlowAction)])
        shakeFastContinuous = SKAction.sequence([stopShaking, SKAction.repeatActionForever(shakeFastAction)])
    }
    
    func getShakeForDirection(direction:UInt) -> SKAction {
        switch(direction){
            case Direction.Left: return shakeActionLeft
            case Direction.Right: return shakeActionRight
            case Direction.Up: return shakeActionUp
            case Direction.Down: return shakeActionDown
            default: return shakeActionNone
        }
    }
    
    
    func createMoveUpAndDown(amount:CGFloat) -> SKAction {
        let moveUpSlowly = SKAction.moveBy(CGVectorMake(0, +amount), duration: 0.1)
        let moveDownSlowly = SKAction.moveBy(CGVectorMake(0, -amount), duration: 0.1)
        let moveUpAndDownSlowly = SKAction.repeatActionForever(SKAction.sequence([
            moveUpSlowly,
            moveDownSlowly,
            moveDownSlowly,
            moveUpSlowly
            ]))
        return moveUpAndDownSlowly
    }
    
    
    func createMoveLeftAndRight(amount:CGFloat) -> SKAction {
        let frame1 = SKAction.moveBy(CGVectorMake(+amount,0), duration: 0.1)
        let frame2 = SKAction.moveBy(CGVectorMake(-amount,0), duration: 0.1)
        let all = SKAction.repeatActionForever(SKAction.sequence([
            frame1,
            frame2,
            frame2,
            frame1
            ]))
        return all
    }
    
//    func createPopInAction(point:CGPoint) -> SKAction {
//        let moveDown = SKAction.moveTo(point, duration: 0.3)
//        let moveIn = SKAction.group([moveDown,fadeIn])
//        return SKAction.sequence([delay,moveIn,raiseEntityLanded])
//    }
    
    func createPopInAction(node:SKNode, destination:CGPoint, duration:CGFloat = 0.3) -> SKAction {
        let start = node.position
        let moveDownEffect = SKTMoveEffect(node: node, duration: duration, startPos: start, endPos: destination)
        moveDownEffect.timingFunction = SKTTimingFunctions.CubicEaseIn
        let moveDownAction = SKAction.actionWithEffect(moveDownEffect)
        let fadeIn = SKAction.fadeInWithDuration(NSTimeInterval(duration))
        let popInAction = SKAction.group([moveDownAction, fadeIn])
        return SKAction.sequence([delay,popInAction])
    }

    

    func createPopInActionWithoutDelay(node:SKNode, destination:CGPoint, duration:CGFloat = 0.3) -> SKAction {
        let start = node.position
        let moveDownEffect = SKTMoveEffect(node: node, duration: duration, startPos: start, endPos: destination)
        moveDownEffect.timingFunction = SKTTimingFunctions.CubicEaseIn
        let moveDownAction = SKAction.actionWithEffect(moveDownEffect)
        let fadeIn = SKAction.fadeInWithDuration(NSTimeInterval(duration))
        let popInAction = SKAction.group([moveDownAction, fadeIn])
        return popInAction
    }

    
    
    
    // singleton pattern
    class var sharedInstance: ActionFactory {
    struct Singleton {
        static let instance = ActionFactory()
        }
        return Singleton.instance
    }
}

