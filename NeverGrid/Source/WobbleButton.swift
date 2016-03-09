//
//  WobbleButton.swift
//  NeverGrid
//
//  Created by Benzi on 26/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class WobbleButton : TouchableNode {
    
    var action:TargetAction? = nil
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
    }
    
    init(node:SKNode, action:TargetAction) {
        self.action = action
        super.init(node: node)
        super.onTouchBegan = Callback(self,WobbleButton.onTouchBegan)
        super.onTouchEnded = Callback(self,WobbleButton.onTouchEnded)
        super.onTouchCancelled = Callback(self,WobbleButton.onTouchEnded)
    }
    
    func onTouchBegan() {
        if GameSettings().soundEnabled {
            self.runAction(ActionFactory.sharedInstance.playMenuSelection)
        }
    }
    
    func onTouchEnded() {
        self.containedNode.runAction(SKAction.wobble()) {
            [weak self] in
            if let a = self!.action {
                a.performAction()
            }
        }
    }
}

extension SKNode {
    func makeWobbleButton(action:TargetAction) -> WobbleButton {
        if let parent = self.parent {
            self.removeFromParent()
            let position = self.position
            self.position = CGPointZero
            let button = WobbleButton(node: self, action: action)
            button.position = position
            parent.addChild(button)
            return button
        } else {
            let button = WobbleButton(node: self, action: action)
            return button
        }
    }
}