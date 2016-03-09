//
//  ParallelActionController.swift
//  OnGettingThere
//
//  Created by Benzi on 21/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// a controller that guarantees its completion handler will
/// be called only after all child actions/controllers finish
/// executing, even if actions are async
/// provided that actions/controllers themselves do not internally
/// create any new async actions (sync type actions are OK)
/// and the start and completion handlers are synchronous
class ParallelActionController : EntityActionController {
    
    override init(world:WorldMapper) {
        super.init(world:world)
        super.name = "ParallelActionController"
    }
    
    var controllers = [EntityActionController]()
    var actionsFinished = 0
    var totalActions = 0
    
    func onCompletion() {
        self.actionsFinished++
        if self.actionsFinished == self.totalActions {
            self.completionHandler?.performAction()
            self.needsToRun = false
        }
    }
    
    /// adds the specified action to the action queue
    override func add(action: EntityAction) {
        let controller = EntityActionController(world: world)
        controller.name = "\(name)[ControllerForAction]"
        controller.completionHandler = Callback(self, ParallelActionController.onCompletion)
        controller.add(action)
        controllers.append(controller)
        totalActions+=1
    }
    
    /// defaults to add behaviour because
    /// in parallel scheme, it doesnt matter
    /// at which position you add an action
    /// action order does not matter
    override func insert(action: EntityAction) {
        add(action)
    }
    

    
    class TargetActionCombiner {
        var action1: TargetAction
        var action2: TargetAction
        init(a:TargetAction, b:TargetAction) {
            self.action1 = a
            self.action2 = b
        }
        func run() {
            action1.performAction()
            action2.performAction()
        }
    }
    
    
    
    // we need to keep a reference to all instances
    // of TargetActionCombiner we create
    // because TargetActionWrapper internally holds
    // a weak reference to the target, we need to 
    // hold a strong reference to it somewhere
    // this array will (should) get reset in the reset() call
    var combinedCompletionHandlers = [TargetActionCombiner]()
    
    func combine(a:TargetAction, b:TargetAction) -> TargetAction {
        let combinator = TargetActionCombiner(a: a, b: b)
        let combinedAction = Callback(combinator, TargetActionCombiner.run)
        combinedCompletionHandlers.append(combinator)
        return combinedAction
    }
    
    
    /// adds the specified controller to the run queue
    func add(controller:EntityActionController) {
        
        // modify the completion handler so that
        // the parallel controller's onCompletion
        // method is invoked
        
        controller.name = "\(name)[\(controller.name)]"
        if controller.completionHandler != nil {
            controller.completionHandler = combine(
                controller.completionHandler!,
                b: Callback(self, ParallelActionController.onCompletion)
            )
        } else {
            controller.completionHandler = Callback(self, ParallelActionController.onCompletion)
        }
        controllers.append(controller)
        totalActions+=1
    }
    
    func reset() {
        actionsFinished = 0
        totalActions = 0
        runNextIndex = 0
        combinedCompletionHandlers.removeAll(keepCapacity: true)
        controllers.removeAll(keepCapacity: true)
    }
    
    override func end() { } // do nothing here, end will be called only when all actions are completed

    
    
    // MARK: Default Mode
    // default mode of running the controller, fire and forget
    
    override func run() {
        for controller in controllers {
            controller.run()
        }
    }
    
    // MARK: Controlled Mode
    // per frame mode of running the parallel controller
    
    var needsToRun = false
    private var runNextIndex = 0
    
    // allows to run in a controlled fashion, example in per frame updates
    func runNext() -> Bool {
        let totalControllers = controllers.count
        if runNextIndex < totalControllers {
            let controller = controllers[runNextIndex]
            runNextIndex++
            controller.run()
            return true
        } else {
            return false
        }
    }
    
    func lastRunController() -> EntityActionController {
        return controllers[runNextIndex-1]
    }
    
    var remainingControllerCount:Int {
        return controllers.count - runNextIndex
    }
    
    
    let FRAME_INTERVAL_LIMIT:CFTimeInterval = 1.0/60.0
    
    override func update() {
        
        let start = CFAbsoluteTimeGetCurrent()
        var timeTaken:CFTimeInterval = 0.0
        for controller in controllers {
            
            // as long as a controller is ready to update
            // keep updating it within frame interval limit
            while (controller._state.value == ActionControllerState.Ready.rawValue || controller._state.value == ActionControllerState.NotStarted.rawValue)
                && timeTaken < FRAME_INTERVAL_LIMIT
            {
                
                controller.update()
                timeTaken = (CFAbsoluteTimeGetCurrent() - start)
            }
            
            // if we crossed the frame interval limit, skip
            if timeTaken > FRAME_INTERVAL_LIMIT {
                
                // clean up finished controllers so that next update 
                // we do not need to cycle through them
                var i = 0
                while i < controllers.count {
                    if controllers[i].processingComplete {
                        controllers.removeAtIndex(i)
                    }
                    else if controllers[i]._state.value == ActionControllerState.NotStarted.rawValue {
                        break
                    }
                    else {
                        i++
                    }
                }
                return
            }
            
            // else we continue with next controller in loop
        }
    }
}
