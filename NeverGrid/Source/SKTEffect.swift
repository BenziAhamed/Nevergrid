//
//  SKTEffect.swift
//  gettingthere
//
//  Created by Benzi on 15/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

//typedef float (^SKTTimingFunction)(float y);
typealias SKTTimingFunction=(CGFloat)->CGFloat

struct SKTTimingFunctions {
    static let Linear:SKTTimingFunction = { return $0 }
    static let SmoothStep:SKTTimingFunction = { return $0*$0*(3-2*$0) }

    static let QuadraticEaseIn:SKTTimingFunction = { return $0*$0 }
    static let QuadraticEaseOut:SKTTimingFunction = { return $0*(2.0-$0) }
    static let QuadraticEaseInOut:SKTTimingFunction = { (t) in
        if t < 0.5 {
            return 2.0 * t * t
        } else {
            let f = t - 1.0
            return 1.0 - 2.0 * f * f
        }
    }
    
    
    static let CubicEaseIn:SKTTimingFunction = { return $0*$0*$0 }
    static let CubicEaseOut:SKTTimingFunction = { (t) in
        let f = t - 1.0
        return 1.0 + f * f * f
    }
    static let CubicEaseInOut:SKTTimingFunction = { (t) in
        if (t < 0.5) {
            return 4.0 * t * t * t;
        } else {
            let f = t - 1.0;
            return 1.0 + 4.0 * f * f * f;
        }
    }
    
    
//    static let QuarticEaseIn:SKTTimingFunction = { return $0*$0*$0*$0 }
//    static let QuarticEaseOut:SKTTimingFunction = { (t) in
//        let f = t - 1.0;
//        return 1.0 - f * f * f * f;
//    }
//    static let QuarticEaseInOut:SKTTimingFunction = { (t) in
//        if (t < 0.5) {
//            return 8.0 * t * t * t * t;
//        } else {
//            let f = t - 1.0;
//            return 1.0 - 8.0 * f * f * f * f;
//        }
//    }
//    
//    
//    static let SineEaseIn:SKTTimingFunction = { (t) in
//        return sin((t - 1.0) * M_PI_2) + 1.0;
//    }
//    static let SineEaseOut:SKTTimingFunction = { (t) in
//        return sin(t * M_PI_2)
//    }
//    static let SineEaseInOut:SKTTimingFunction = { (t) in
//        return 0.5 * (1.0 - cos(t * M_PI))
//    }
//    
//    
//    static let CircularEaseIn:SKTTimingFunction = { (t) in
//        return 1.0 - sqrt(1.0 - t * t)
//    }
//    static let CircularEaseOut:SKTTimingFunction = { (t) in
//        return sqrt((2.0 - t) * t)
//    }
//    static let CircularEaseInOut:SKTTimingFunction = { (t) in
//        if (t < 0.5) {
//            return 0.5 * (1.0 - sqrt(1.0 - 4.0 * t * t));
//        } else {
//            return 0.5 * sqrt(-4.0 * t * t + 8.0 * t - 3.0) + 0.5;
//        }
//    }
//    
//    
//    
//    static let ExponentialEaseIn:SKTTimingFunction = { (t) in
//        return (t == 0.0) ? t : pow(2.0, 10.0 * (t - 1.0))
//    }
//    static let ExponentialEaseOut:SKTTimingFunction = { (t) in
//        return (t == 1.0) ? t : 1.0 - pow(2.0, -10.0 * t)
//    }
//    static let ExponentialEaseInOut:SKTTimingFunction = { (t) in
//        if (t == 0.0 || t == 1.0) {
//            return t;
//        } else if (t < 0.5) {
//            return 0.5 * pow(2.0, 20.0 * t - 10.0);
//        } else {
//            return 1.0 - 0.5 * pow(2.0, -20.0 * t + 10.0);
//        }
//    }
//    
//    
//    static let ElasticEaseIn:SKTTimingFunction = { (t) in
//        return sin(13.0 * M_PI_2 * t) * pow(2.0, 10.0 * (t - 1.0))
//    }
//    static let ElasticEaseOut:SKTTimingFunction = { (t) in
//        return sin(-13.0 * M_PI_2 * (t + 1.0)) * pow(2.0, -10.0 * t) + 1.0
//    }
//    static let ElasticEaseInOut:SKTTimingFunction = { (t) in
//        if (t < 0.5) {
//            return 0.5 * sin(13.0 * M_PI * t) * pow(2.0, 20.0 * t - 10.0);
//        } else {
//            return 0.5 * sin(-13.0 * M_PI * t) * pow(2.0, -20.0 * t + 10.0) + 1.0;
//        }
//    }
//    
//    
//    static let BackEaseIn:SKTTimingFunction = { (t) in
//        let s = 1.70158
//        return ((s + 1.0) * t - s) * t * t
//    }
//    static let BackEaseOut:SKTTimingFunction = { (t) in
//        let s = 1.70158
//        let f = 1.0 - t
//        return 1.0 - ((s + 1.0) * f - s) * f * f
//    }
//    static let BackEaseInOut:SKTTimingFunction = { (t) in
//        let s = 1.70158
//        if (t < 0.5) {
//            let f = 2.0 * t
//            return 0.5 * ((s + 1.0) * f - s) * f * f;
//        } else {
//            let f = 2.0 * (1.0 - t)
//            return 1.0 - 0.5 * ((s + 1.0) * f - s) * f * f;
//        }
//    }
//    
//    
//    static let BounceEaseIn:SKTTimingFunction = { (t) in
//        return 1.0 - BounceEaseOut(1.0 - t)
//    }
//    static let BounceEaseOut:SKTTimingFunction = { (t) in
//        if (t < 1.0 / 2.75) {
//            return 7.5625 * t * t
//        } else if (t < 2.0 / 2.75) {
//            var t1 = t - (1.5 / 2.75)
//            return 7.5625 * t1 * t1 + 0.75
//        } else if (t < 2.5 / 2.75) {
//            var t1 = t - (2.25 / 2.75)
//            return 7.5625 * t1 * t1 + 0.9375
//        } else {
//            var t1 = t - (2.625 / 2.75)
//            return 7.5625 * t1 * t1 + 0.984375
//        }
//    }
//    static let BounceEaseInOut:SKTTimingFunction = { (t) in
//        if (t < 0.5) {
//            return 0.5 * BounceEaseIn(t * 2.0)
//        } else {
//            return 0.5 * BounceEaseOut(t * 2.0 - 1.0) + 0.5
//        }
//    }
//    
    
    
    
    //    static let EaseIn:SKTTimingFunction = { (t) in
    //
    //    }
    //    static let EaseOut:SKTTimingFunction = { (t) in
    //
    //    }
    //    static let EaseInOut:SKTTimingFunction = { (t) in
    //
    //    }
    
}

class SKTEffect {
    weak var node:SKNode?
    var duration:CGFloat
    var timingFunction:SKTTimingFunction
    
    init(node:SKNode,duration:CGFloat){
        self.node = node
        self.duration = duration
        self.timingFunction = SKTTimingFunctions.Linear
    }
    
    func update(t:CGFloat) {}
    
    func toAction() -> SKAction {
        return SKAction.actionWithEffect(self)
    }
}

class SKTMoveEffect:SKTEffect {
    
    var startPos:CGPoint
    var prevPos:CGPoint
    var delta:CGPoint
    
    init(node: SKNode, duration: CGFloat, startPos:CGPoint, endPos:CGPoint)  {
        self.startPos = startPos
        self.prevPos = node.position
        self.delta = endPos.subtract(startPos)
        super.init(node: node, duration: duration)
    }
    
    override func update(t: CGFloat) {
        let newPos = startPos.add(delta.multiply(t))
        let diff = newPos.subtract(prevPos)
        prevPos = newPos
        node!.position = node!.position.add(diff)
    }
}

class SKTScaleEffect:SKTEffect {
    var startScale:CGPoint
    var prevScale:CGPoint
    var delta:CGPoint
    
    init(node: SKNode, duration: CGFloat, startScale:CGPoint, endScale:CGPoint)  {
        self.startScale = startScale
        self.prevScale = CGPointMake(node.xScale, node.yScale)
        self.delta = endScale.subtract(startScale)
        super.init(node: node, duration: duration)
    }
    
    override func update(t: CGFloat) {
        let newScale = startScale.add(delta.multiply(t))
        let diff = newScale.divide(prevScale)
        prevScale = newScale;
        self.node!.xScale *= diff.x
        self.node!.yScale *= diff.y
    }

}