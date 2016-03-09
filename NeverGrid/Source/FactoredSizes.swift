//
//  FactoredSizes.swift
//  NeverGrid
//
//  Created by Benzi on 23/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

struct FactoredSizes {
    
    static let defaultFont = "Luckiest Guy"
    //static let defaultFont = "Vanilla"
    static let numberFont = "Luckiest Guy"
    
    struct AnimationSystem {
        static let stepSizeForFallingCells:CGFloat = factor(forPhone: 0.25, forPad: 0.20)
    }
    
    struct GameFrame {
        static let TitleSpace:CGFloat = factor(forPhone: -36.0, forPad: -64.0)
    }
    
    struct CameraSystem {
        // by how much should the active bounds cover the game frame
        static let targetFrameSize:CGFloat = factor(forPhone: 0.95, forPad: 0.8)
    }
    
    struct ScalingFactor {
        static let Enemy: CGFloat =  factor(forPhone: 0.95, forPad: 0.95) // factor(forPhone: 0.75, forPad: 0.6) * 1.3
        static let Monster: CGFloat =  factor(forPhone: 2.2, forPad: 2.2) // Enemy * 2 * 1.3  roughly
        static let Player: CGFloat = factor(forPhone: 0.95, forPad: 0.95)
        static let Item: CGFloat = factor(forPhone: 0.5, forPad: 0.4)
        static let Portal: CGFloat = factor(forPhone: 0.7, forPad: 0.7)
        static let Glass: CGFloat = factor(forPhone: 0.85, forPad: 0.85)
        
        static let EmotionRelatedToBody: CGFloat = 0.761904762
        static let BodyRelatedToEmotion: CGFloat = 1.3125
    }
    
    struct GameOverSceneBase {
        static let actionButtonY:CGFloat = factor(forPhone: 1.5, forPad: 3.0)
    }
    
    struct LevelSelectionScene {
        static let titleSize:CGFloat = factor(forPhone: 30, forPad: 45)
        static let gridSize:CGFloat = factor2(forPhone: 64.0, forPhone3x: 84.0, forPad: 112.0)
        static let spaceBetweenChapterNodes:CGFloat = factor2(forPhone: 64.0, forPhone3x: 96.0, forPad: 112.0)
    }
    
    struct MenuBar {
        static let paddingLeft = CGPointMake(factor(forPhone: 10.0, forPad: 15.0), 0)
        static let paddingRight = CGPointMake(factor(forPhone: 5, forPad: 10), 0)
    }
    
    struct NavigatingScene {
        static let textBaseOffset:CGFloat = factor(forPhone: 22.0, forPad: 45.0)
    }
    
    struct PhysicsSystem {
        static let thrustFactor:CGFloat = factor(forPhone: 0.7, forPad: 1.0)
    }
    
    struct GameScene {
        static let preferredCellSizeInPoints:CGFloat = factor2(forPhone: 56.0, forPhone3x: 72.0, forPad: 96.0)
    }
}