//
//  MenuBar.swift
//  MrGreen
//
//  Created by Benzi on 09/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit


class MenuBar : SKNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var leftNode = SKNode()
    var rightNode = SKNode()
    
    override init() {
        super.init()
        addChild(leftNode)
        addChild(rightNode)
    }
    

    func addLeft(node:SKNode) {
        
        var minX = node.position.x
        
        minX += FactoredSizes.MenuBar.paddingLeft.x
        
        for c in leftNode.children as [SKNode] {
            minX += c.calculateAccumulatedFrame().width
            minX += FactoredSizes.MenuBar.paddingLeft.x
            minX += FactoredSizes.MenuBar.paddingLeft.x // add it twice for extra spacing
        }
        
        minX += node.calculateAccumulatedFrame().width / 2.0
        
        node.position = CGPointMake( minX, node.position.y )
        
        leftNode.addChild(node)
    }
    
    func addRight(node:SKNode) {
        
        var maxX = node.position.x
        
//        println("maxX -> \(maxX)")
        
        if rightNode.children.count == 0 {
            maxX -= FactoredSizes.MenuBar.paddingRight.x
//            println("no children, so maxX -> \(maxX)")
        }
        
        for c in rightNode.children as [SKNode] {
            maxX -= c.calculateAccumulatedFrame().width
            maxX -= FactoredSizes.MenuBar.paddingRight.x
            
//            println("child bounds: \(c.calculateAccumulatedFrame())")
//            println("child found, so maxX -> \(maxX)")
        }
        
        let position = node.position
        let x = maxX - node.calculateAccumulatedFrame().width / 2.0
        
//        println("current node bounds: \(node.calculateAccumulatedFrame())")
//        println("final x -> \(x)")
//        println("--------")
        
        node.position = CGPointMake(x, position.y)
        
        rightNode.addChild(node)
    }
    
}