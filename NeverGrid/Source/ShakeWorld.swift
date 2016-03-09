//
//  ShakeWorld.swift
//  NeverGrid
//
//  Created by Benzi on 21/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class ShakeWorld : EntityAction {
    
    override var description:String { return "ShakeWorld" }
    
    override func perform() -> SKAction? {
        world.scene!.cameraNode.runAction(SKAction.shake(0.3))
        return nil
    }
    
}