//
//  HintNode.swift
//  NeverGrid
//
//  Created by Benzi on 15/03/15.
//  Copyright (c) 2015 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class HintNode: SKNode {
    
    var index = -1
    var hints = [SKSpriteNode]()
    var targetMessagePosition:CGPoint!
    var hidePoint:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(hints:[String], frame:CGRect) {
        
        super.init()
        
        // player
        let player = textSprite("player")
        let playerHeight = player.frame.height
        
        // create message nodes all hidden from view
        hidePoint = CGPointMake(frame.midX, frame.height+10.0)
        var maximumMessageHeight:CGFloat = 0.0
        for hint in hints {
            let node = messageSprite(hint)
            self.hints.append(node)
            node.anchorPoint = CGPointMake(0.5, 0.0)
            node.position = hidePoint
            
            if node.frame.height > maximumMessageHeight {
                maximumMessageHeight = node.frame.height
            }
            
            self.addChild(node)
        }
        
        // find player position
        player.position = CGPointMake (
            frame.midX,
            (frame.height - maximumMessageHeight)/2.0
            // (H - (M + P))/2 + P/2 ; H=total height, M=messgae, P=player
        )
        self.addChild(player)
        
        targetMessagePosition = player.position.offset(dx: 0.0, dy: player.frame.height/2.0)
    }
    
    func displayHint() {
        if index >= 0 {
            hideHint(hints[index])
        }
        index++
        showHint(hints[index])
    }
    
    func hasFurtherHints() -> Bool {
        return index < hints.count-1
    }
    
    func reset() {
        // hide all messages
        // scale all messages to 1.0
        for hint in hints {
            hint.position = hidePoint
            hint.setScale(1.0)
        }
        // reset index to -1
        index = -1
    }
    
    
    private func hideHint(hint:SKSpriteNode) {
        hint.runAction(
            SKAction.scaleTo(0.0, duration: 0.2)
        )
    }
    
    private func showHint(hint:SKSpriteNode) {
        hint.runAction(
            SKAction.moveTo(targetMessagePosition, duration: 0.3)
        )
    }
}