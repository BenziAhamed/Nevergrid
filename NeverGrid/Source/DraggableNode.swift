//
//  DraggableNode.swift
//  OnGettingThere
//
//  Created by Benzi on 31/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class DraggableNode : SKNode {
    
    enum DragConstraint {
        case Vertical
        case Horizontal
        case None
    }
    
    var draggedNode: SKNode!
    var dragging = false
    var deccelerating = false
    var beingMoved = false
   
    var dragStart:CGPoint!
    var dragOffset:CGPoint!
    var dragFactor:CGPoint = CGPointMake(1.0,1.0)
    let minDragDistance:CGFloat = 10.0
    
    var isMultiTouch = false
    
    
    var velocity = CGPointZero
    var lastTouchLocation:CGPoint!
    var lastTouchTimestamp:NSTimeInterval!
    var lastTouchedNode:SKNode?
    
    var onContainedNodeTouched:TargetAction?
    var onDragCompleted:TargetAction?
    
    var shouldConstrainX = false
    var constrainX:(CGFloat,CGFloat)! {
    didSet { shouldConstrainX = true }
    }
    
    var shouldConstrainY = false
    var constrainY:(CGFloat,CGFloat)! {
    didSet { shouldConstrainY = true }
    }
    
    var dragConstraint:DragConstraint = DragConstraint.None {
    didSet {
        switch(dragConstraint) {
        case .None: dragFactor = CGPointMake(1.0,1.0)
        case .Vertical: dragFactor = CGPointMake(0.0,1.0)
        case .Horizontal: dragFactor = CGPointMake(1.0,0.0)
        }
    }
    }
    
    init(node:SKNode) {
        self.draggedNode = node
        super.init()
        self.userInteractionEnabled = true
        self.addChild(draggedNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// determines if the node is undergoing any movement
    /// returns true if we are being dragged, deccelerated, or
    /// explicitly set to move to a point
    var inMotion:Bool {
        return dragging || deccelerating || beingMoved
    }
    
    func setOurDraggedNode(node:SKNode) {
        self.removeAllChildren()
        self.draggedNode = node
        self.addChild(draggedNode)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // if this is a multi touch event, we ignore it
        if touches.count > 1 {
            isMultiTouch = true
            return
        }
        
        // this is the start of a single touch drag event
        // record the starting positions of the drag event
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        // the starting point of the possible drag operation
        dragStart = touchLocation
        
        // the offset to the contained node, used for delta corrections later on
        dragOffset = draggedNode.position.subtract(touchLocation)
        
        
        // velocity specific
        lastTouchLocation = touchLocation
        lastTouchTimestamp = touch.timestamp
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // if this is a multi touch event, we ignore it
        if isMultiTouch || touches.count > 1 {
            return
        }
        
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        // if we were already dragging, continue to drag
        if dragging {
            drag(touchLocation)
        }
            
            // if we we are not dragging already, check if we need to start dragging
            // based on a minimum start distance, just so that we nudge enough
            // to physically move the object
        else if !dragging && touchLocation.distanceTo(dragStart) > minDragDistance {
            dragging = true
            drag(touchLocation)
        }
        
        if dragging {
            // calculate the velocity of our touch
            let distance = lastTouchLocation.distanceTo(touchLocation)
            let time = CGFloat(touch.timestamp - lastTouchTimestamp)
            velocity = CGPointMake(
                (touchLocation.x-lastTouchLocation.x)/time,
                (touchLocation.y-lastTouchLocation.y)/time
                ).multiply(dragFactor)
            lastTouchLocation = touchLocation
            lastTouchTimestamp = touch.timestamp
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // if this is not a multi touch event, and the final touch is with one finger
        // and we were not dragging until now, register a touch event and call the
        // touch handler instead
        if !isMultiTouch && touches.count == 1 && !dragging {
            let touchLocation = (touches.first!).locationInNode(self)
            lastTouchedNode = nodeAtPoint(touchLocation)
            onContainedNodeTouched?.performAction()
        }
        
        // reset
        dragging = false
        isMultiTouch = false
    }
    
    
    func update(dt:Double) {
        if velocity == CGPointZero || dragging || isMultiTouch {
            return
        }
        
        
        deccelerating = true
        
        let newPosition = draggedNode.position.add(velocity.multiply(CGFloat(dt)))
        let constrainedPosition = constrain(newPosition)
        draggedNode.position = constrainedPosition
        velocity = velocity.multiply(0.9)
        
        // if we were constrained or the velocity is now quite small
        if (abs(velocity.x) < 4 && abs(velocity.y) < 4) || (constrainedPosition != newPosition) {
            velocity = CGPointZero
            deccelerating = false
            onDragCompleted?.performAction()
        }
        
        //println("velocity: \(velocity) points/sec")
    }
    
    
    func drag(point:CGPoint) {
        var newPosition = point.add(dragOffset).multiply(dragFactor)
        newPosition = constrain(newPosition)
        draggedNode.position = newPosition
    }
    
    func translateLogicalToWorld(point:CGPoint) -> CGPoint {
        let target = CGPointMake(shouldConstrainX ? constrainX.1 : 0.0, shouldConstrainY ? constrainY.1 : 0.0).subtract(point)
        return target
    }
    
    func moveTo(point:CGPoint, duration:NSTimeInterval=0.5) {
        
        var target = translateLogicalToWorld(point)
        target = constrain(target.multiply(dragFactor))
        
        //println("point:\(point) translated to target:\(target)")
        
        if duration == 0 {
            draggedNode.position = target
        }
        else {
            beingMoved = true
            draggedNode.runAction(SKAction.moveTo(target, duration: duration)) {
                [weak self] in
                self!.beingMoved = false
            }
        }
    }
    
    func constrain(point:CGPoint) -> CGPoint {
        var p = point
        if shouldConstrainX {
            p = p.clampX(constrainX)
        }
        if shouldConstrainY {
            p = p.clampY(constrainY)
        }
        return p
    }
}