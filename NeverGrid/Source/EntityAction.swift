//
//  EntityAction.swift
//  gettingthere
//
//  Created by Benzi on 12/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit



// base class for entity actions
class EntityAction {
    
    var description:String { return "BASE CLASS: ENTITY ACTION" }
    
    
    /// determines if this action will block all following actions
    /// in its parent controller
    var isBlocking = false
    
    
    /// perform the action, returns an SKAction
    /// in case SpriteKit's SKAction needs to be used
    /// either for animations or running code in a block
    func perform() -> SKAction? { return nil }
    
    
    /// determines if the controller should wait for this action
    /// to finish execution before proceeding to process other actions
    /// in the action list
    /// NOTE: this makes sense only for actions that return an SKAction
    var shouldWaitForActionCompletion = true
    
    
    /// a reference to the parent contoller that will manage this action
    weak var controller:EntityActionController? = nil
    
    
    /// the entity for which the action needs to be run
    var entity:Entity
    
    /// reference to the world game component
    var world:WorldMapper
    
    init(entity:Entity, world:WorldMapper) {
        self.entity = entity
        self.world = world
    }
}


///// an action that forces a nonblocking behaviour
///// on the cotaining action
///// WARNING: This is only as a proof of concept!
///// do not use!!
//class ForceNonBlockingBehaviour : EntityAction {
//    override var isBlocking:Bool { get {return false} set{} } // never blocks
//    var containedAction:EntityAction
//    init(action:EntityAction) {
//        self.containedAction = action
//        super.init(entity: action.entity, world: action.world)
//    }
//    override func perform() -> SKAction? {
//        return containedAction.perform()
//    }
//}
//
///// an action that forces a blocking behaviour
///// on the cotaining action
///// WARNING: This is only as a proof of concept!
///// do not use!!
//class ForceBlockingBehaviour : EntityAction {
//    override var isBlocking:Bool { get {return true} set{} } // always blocks
//    var containedAction:EntityAction
//    init(action:EntityAction) {
//        self.containedAction = action
//        super.init(entity: action.entity, world: action.world)
//    }
//    override func perform() -> SKAction? {
//        return containedAction.perform()
//    }
//}








