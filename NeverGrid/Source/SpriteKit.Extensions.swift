//
//  SpriteKit.Extensions.swift
//  MrGreen
//
//  Created by Benzi on 08/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension SKSpriteNode {
    func adjustSizeForIpad() {
        if usingIpad {
            self.size = self.size.scale(1.5)
        }
    }
}


extension SKNode {
    func setItem(key:String, value:AnyObject) {
        if self.userData == nil {
            self.userData = NSMutableDictionary()
        }
        self.userData!.setObject(value, forKey: key)
    }
    
    func getItem(key:String) -> AnyObject? {
        if self.userData == nil { return nil }
        return self.userData!.objectForKey(key)
    }
}

extension SKEmitterNode {
    class func emitterNodeWithName(name: String) -> SKEmitterNode {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource(name, ofType: "sks")!) as! SKEmitterNode
    }
    
    func runOneShot(duration: CGFloat) {
        let waitAction = SKAction.waitForDuration(NSTimeInterval(duration))
        let birthRateSet = SKAction.runBlock { self.particleBirthRate = 0.0 }
        let waitAction2 = SKAction.waitForDuration(NSTimeInterval(self.particleLifetime + self.particleLifetimeRange))
        let removeAction = SKAction.removeFromParent()
        
        let sequence = [ waitAction, birthRateSet, waitAction2, removeAction]
        self.runAction(SKAction.sequence(sequence))
    }
}
extension SKTextureAtlas {
    
    class func atlasWithName(var name:String) -> SKTextureAtlas {
        if usingIpad {
            name = name + "_ipad"
        } else {
            if usingIphoneWidescreen {
                name = name + "_widescreen"
            } else if usingIphone6 {
                name = name + "_iphone6"
            } else if usingIphone6plus {
                name = name + "_iphone6plus"
            }
        }
        return SKTextureAtlas(named: name)
    }
}

extension SKNode {
    
    func childBounds(master:SKNode, child:SKNode) -> CGRect {
        var bounds = CGRectZero
        
        if child.children.count == 0 {
            let cp = master.convertPoint(child.position, fromNode: child.parent!)
            bounds = CGRectMake(cp.x, cp.y, child.frame.width, child.frame.height)
        } else {
            for c in child.children as [SKNode] {
                bounds = CGRectUnion(bounds, c.childBounds(master, child:c))
            }
        }
        return bounds
    }
    
    // calculates the accumulated bounds of this node
    // based on all child nodes
    func bounds() -> CGRect {
        var bounds = CGRectZero
        if self.children.count == 0 {
            bounds = self.frame
        } else {
            for c in self.children as [SKNode] {
                bounds = CGRectUnion(bounds, childBounds(self, child: c))
            }
        }
        
        //println("node \(self) bounds = \(bounds)")
        return bounds
    }
}

extension SKAction {
    class func shake(duration:CGFloat, amplitudeX:CGFloat = 2.0, amplitudeY:CGFloat = 2.0) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for index in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2.0)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2.0)
            let forward = SKAction.moveByX(dx, y:dy, duration: 0.015)
            let reverse = forward.reversedAction()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
    
    class func actionWithEffect(effect:SKTEffect) -> SKAction {
        return SKAction.customActionWithDuration(NSTimeInterval(effect.duration)) {
            (node:SKNode,elapsedTime:CGFloat) in
            var t = elapsedTime/effect.duration
            t = effect.timingFunction(t)
            effect.update(t)
        }
    }
    
    
    class func wobble() -> SKAction {
        let scaleUp1 = SKAction.scaleTo(1.07, duration: 0.1)
        let scaleDown1 = SKAction.scaleTo(0.95, duration: 0.1)
        let scaleUp2 = SKAction.scaleTo(1.05, duration: 0.1)
        let scaleDown2 = SKAction.scaleTo(1.0, duration: 0.1)
        let wobble = SKAction.sequence([scaleUp1,scaleDown1,scaleUp2,scaleDown2])
        return wobble
    }
    
    class func wobble2() -> SKAction {
        let scaleUp1 = SKAction.scaleBy(1.07, duration: 0.1)
        let scaleDown1 = SKAction.scaleBy(0.95, duration: 0.1)
        let scaleUp2 = SKAction.scaleBy(1.05, duration: 0.1)
        let scaleDown2 = SKAction.scaleBy(1.0, duration: 0.1)
        let wobble = SKAction.sequence([scaleUp1,scaleDown1,scaleUp2,scaleDown2])
        return wobble
    }
}

extension SKAction {
    func followedBy(with:SKAction) -> SKAction {
        return SKAction.sequence([self, with])
    }
    
    func alongside(with:SKAction) -> SKAction {
        return SKAction.group([self, with])
    }
    
    func timing(mode:SKActionTimingMode) -> SKAction {
        self.timingMode = mode
        return self
    }
}


class NodeHelper<T> {
    // finds the first self node/parent node that matches T
    class func matchSelfOrParent(node:SKNode) -> T? {
        if node is T { return node as? T }
        var current = node
        while (current.parent != nil) {
            if current.parent is T { return current.parent as? T }
            current = current.parent!
        }
        return nil
    }

    // finds the first child node that matches T
    class func matchSelfOrChild(node:SKNode) -> T? {
        if node is T { return node as? T }
        let current = node
        let visitChildren = Stack<SKNode>()
        for c in current.children as [SKNode] {
            visitChildren.push(c)
        }
        while(visitChildren.items.count>0) {
            let child = visitChildren.pop()
            if child is T { return child as? T }
            else {
                for c in child.children as [SKNode] {
                    visitChildren.push(c)
                }
            }
        }
        return nil
    }
}