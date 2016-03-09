//
//  TouchableNode.swift
//  OnGettingThere
//
//  Created by Benzi on 02/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class TouchableNode : SKNode {
    
    var onTouchBegan:TargetAction?
    var onTouchEnded:TargetAction?
    var onTouchCancelled:TargetAction?

    
    var containedNode:SKNode!
    var handlingTouch = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(node:SKNode) {
        self.containedNode = node
        super.init()
        super.userInteractionEnabled = true
        super.addChild(containedNode)
        
        // hack to increase the touch bounds
        let touchSprite = SKSpriteNode(
            texture: nil,
            color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0),
            size: getTouchBounds(node.calculateAccumulatedFrame()).size
        )
        super.addChild(touchSprite)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            
            
            
            let touch = touches.first!
            let touchLocation = touch.locationInNode(self)
            let containedNodeBounds = self.containedNode.calculateAccumulatedFrame()
            let containedNodeTouchBounds = getTouchBounds(containedNodeBounds)
//            println("overall bounds: \(containedNodeBounds)")
//            println("touch location: \(touchLocation)")

        
            if containedNodeTouchBounds.contains(touchLocation) {
                handlingTouch = true
                onTouchBegan?.performAction()
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if !handlingTouch { return }
        
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        let containedNodeBounds = self.containedNode.calculateAccumulatedFrame()
        let containedNodeTouchBounds = getTouchBounds(containedNodeBounds)
        
//        println("touch location: \(touchLocation)")
//        
//        println("   node bounds: \(containedNodeBounds)")
//        println("  touch bounds: \(containedNodeTouchBounds)")
//        
//        println("original w \(containedNodeBounds.width) x h \(containedNodeBounds.height)")
//        println("new      w \(containedNodeTouchBounds.width) x h \(containedNodeTouchBounds.height)")
        
        
        
        if containedNodeTouchBounds.contains(touchLocation) {

//            println("inside")
            onTouchEnded?.performAction()
        } else {
//            println("outside")
            onTouchCancelled?.performAction()
        }
        
        handlingTouch = false
    }
    
    func getTouchBounds(frame:CGRect) -> CGRect {
        let factor = min(frame.width, frame.height)
        return frame.insetBy(dx: -0.5*factor, dy: -0.5*factor)
    }
}
