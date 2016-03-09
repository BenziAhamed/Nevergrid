//
//  PlayerSystem.swift
//  gettingthere
//
//  Created by Benzi on 23/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerSystem : System {

    
    override init(_ world: WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.DoPlayerMove, handler: self)
        world.eventBus.subscribe(GameEvent.AICompleted, handler: self)
    }

    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
            
        case GameEvent.DoPlayerMove:
            performPlayerTurn(data as! UInt)
            
        case GameEvent.AICompleted:
            CheckStuck(entity: world.mainPlayer, world: world).perform()
            
        default: break
        }
    }
    
    func performPlayerTurn(moveDirection:UInt) {
        let controller = createPlayerController(moveDirection)
        controller.run()
        
//        playerController = createPlayerController(moveDirection)
    }
    
    
    
    func createPlayerController(moveDirection:UInt) -> PlayerController {
        // does the player have slide activated?
        if world.slide.belongsTo(world.mainPlayer){
            return SlidingPlayerController(world: self.world, moveDirection: moveDirection)
        } else {
            // normal mode
            return DefaultPlayerController(world: self.world, moveDirection: moveDirection)
        }
    }
    
    //    var playerController:EntityActionController?
    //    override func update(dt: Double) {
    //        if let controller = playerController {
    //            controller.update()
    //            if controller.processingComplete {
    //                playerController = nil
    //            }
    //        }
    //    }

}
