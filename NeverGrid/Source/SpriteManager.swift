//
//  SpriteManager.swift
//  gettingthere
//
//  Created by Benzi on 01/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class SpriteManager {
    
    struct Shared {
        static let gameover = SpriteManager(atlasName: "GameOverSprites")
        static let entities = SpriteManager(atlasName: "EntitySprites")
        static let grid = SpriteManager(atlasName: "GridSprites")
        static let text = SpriteManager(atlasName: "TextSprites")
        static let clouds = SpriteManager(atlasName: "CloudSprites")
        static let messages = SpriteManager(atlasName: "HelpMessageSprites")
        
        static func preload(callback:()->Void) {
            let atlases = [
                gameover.atlas,
                entities.atlas,
                grid.atlas,
                text.atlas,
                clouds.atlas
            ]
            SKTextureAtlas.preloadTextureAtlases(atlases, withCompletionHandler: callback)
        }
    }
    
    var atlas:SKTextureAtlas
    
    
    // provides a mechanism to load a texture
    // textures are cached
    func texture(name:String) -> SKTexture {
        return atlas.textureNamed(name)
    }
    
    
    init(atlasName:String, useSizeTraits:Bool = false)
    {
        if useSizeTraits {
            self.atlas = SKTextureAtlas.atlasWithName(atlasName)
        }
        else {
            self.atlas = SKTextureAtlas(named: atlasName)
        }
    }
    
}

func messageSprite(name:String) -> SKSpriteNode {
    let node = SKSpriteNode(texture: SpriteManager.Shared.messages.texture(name))
    node.adjustSizeForIpad()
    return node
}

func textSprite(name:String) -> SKSpriteNode {
    let node = SKSpriteNode(texture: SpriteManager.Shared.text.texture(name))
    node.adjustSizeForIpad()
    return node
}

func cloudSprite(name:String) -> SKSpriteNode {
    let node = SKSpriteNode(texture: SpriteManager.Shared.clouds.texture(name))
    node.adjustSizeForIpad()
    return node
}

func entitySprite(name:String) -> SKSpriteNode {
    return SKSpriteNode(texture: SpriteManager.Shared.entities.texture(name))
}

func gridSprite(name:String) -> SKSpriteNode {
    return SKSpriteNode(texture: SpriteManager.Shared.grid.texture(name))
}

func backgroundSprite(name:String) -> SKSpriteNode {
    return SKSpriteNode(imageNamed: name)
}

func gameOverSprite(name:String) -> SKSpriteNode {
    let node = SKSpriteNode(texture: SpriteManager.Shared.gameover.texture(name))
    node.adjustSizeForIpad()
    return node
}
