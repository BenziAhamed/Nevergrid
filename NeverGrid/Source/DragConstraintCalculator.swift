//
//  DragConstraintCalculator.swift
//  MrGreen
//
//  Created by Benzi on 27/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol DragConstraintCalculator {
    func calculate(frame frame:CGRect, node:DraggableNode) -> (CGFloat,CGFloat)
}


class HorizontalClipConstraintCalculator : DragConstraintCalculator {
    func calculate(frame frame:CGRect, node:DraggableNode) -> (CGFloat,CGFloat) {
        
        let draggedNodeWidth = node.draggedNode.calculateAccumulatedFrame().width
        
//        var min = frame.origin.x - draggedNodeWidth + frame.width
//        min = clamp(min, frame.origin.x, min)
//        
//        var max = (frame.origin.x + frame.width) - draggedNodeWidth
//        max = clamp(frame.origin.x, max, max)
        
        var magic = (frame.origin.x - draggedNodeWidth) + frame.width
        var min = clamp(magic, max: frame.origin.x, value: magic)
        var max = clamp(frame.origin.x, max: magic, value: magic)
        
        return (min, max)
    }
}

class HorizontalMarginConstraintCalculator : DragConstraintCalculator {
    func calculate(frame frame:CGRect, node:DraggableNode) -> (CGFloat,CGFloat) {
        
        let draggedNodeWidth = node.draggedNode.calculateAccumulatedFrame().width
        
        let margin = 0.2 * frame.width
        
        var magic = (frame.origin.x - draggedNodeWidth) + frame.width
        //var min = clamp(magic, frame.origin.x - margin, magic)
        var max = clamp(frame.origin.x + margin, max: magic, value: magic)
        var min = max - draggedNodeWidth + frame.width - 2.0*margin
        
        return (min, max)
    }
}


class ContentCenteredHorizontalClipConstraintCalculator : HorizontalClipConstraintCalculator {
    override func calculate(frame frame: CGRect, node: DraggableNode) -> (CGFloat, CGFloat) {
        var (min, max) = super.calculate(frame: frame, node: node)
        
        let widthFirst = (node.draggedNode.children[0] as SKNode).calculateAccumulatedFrame().width
        let widthLast = (node.draggedNode.children[node.draggedNode.children.count-1] as SKNode).calculateAccumulatedFrame().width
        
        
        if widthLast < frame.width {
        
        min = min - (frame.width - widthLast)/2.0
        min = clamp(min, max: frame.origin.x, value: min)
        
        }
        
        if widthFirst < frame.width {
        
        max = max + (frame.width - widthFirst)/2.0
        max = clamp(frame.origin.x, max: max, value: max)
        
        }
        
        return (min, max)
    }
}

class ContentWithMarginHorizontalClipConstraintCalculator : HorizontalClipConstraintCalculator {
    
    let margin:CGFloat
    init(margin:CGFloat) {
        self.margin = margin
    }
    
    override func calculate(frame frame: CGRect, node: DraggableNode) -> (CGFloat, CGFloat) {
        var (min, max) = super.calculate(frame: frame, node: node)
        
        
        min = min - margin * frame.width
        max = max + margin * frame.width
        
        min = clamp(min, max: frame.origin.x, value: min)
        max = clamp(frame.origin.x, max: max, value: max)
        
        return (min, max)
    }
}