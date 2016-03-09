//
//  HudNode.swift
//  NeverGrid
//
//  Created by Benzi on 18/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit


class HudNode : SKNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var textNode:SKLabelNode! = nil
    var spriteNode:SKSpriteNode! = nil
    
    init(image:String, text:String) {
        
        super.init()
        
        let textNode = SKLabelNode(fontNamed: FactoredSizes.numberFont)
        textNode.fontColor = UIColor.whiteColor()
        textNode.fontSize = FontSize.HudTextNodeTextSize
        textNode.text = text
        textNode.horizontalAlignmentMode = .Left
        textNode.verticalAlignmentMode = .Center
        
        let spriteNode = entitySprite(image)
        
        // resize icon to text size
        spriteNode.size = CGSizeMake(FontSize.HudTextNodeTextSize,FontSize.HudTextNodeTextSize).scale(0.8)
        
        
        let hudNodeWidth:CGFloat = textNode.frame.width + spriteNode.frame.width
        let spacing:CGFloat = factor2(forPhone: 2.0, forPhone3x: 3.0, forPad: 5.0)
        let textNodeX:CGFloat = -(textNode.frame.width - hudNodeWidth/2.0)
        let spriteNodeX:CGFloat = (textNodeX - spriteNode.frame.width/2.0) - spacing
        
        textNode.position = CGPointMake(textNodeX, 0.0)
        spriteNode.position = CGPointMake(spriteNodeX, 0.0)
        
        self.addChild(spriteNode)
        self.addChild(textNode)
        
        self.textNode = textNode
        self.spriteNode = spriteNode
    }
    
    func set(text:String) {
        textNode.text = text
    }
}


