//
//  ActionController.swift
//  gettingthere
//
//  Created by Benzi on 13/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

enum ActionControllerState : Int, CustomStringConvertible {
    case NotStarted = 1
    /// ready to process a new action
    case Ready = 2
    /// wait for an action to complete
    case Await = 3
    /// controller is blocked
    case Blocked = 4
    /// controller has finished running all actions
    case Completed = 5
    /// controller needs to stop abruptly
    case ForceStop = 6
    
    var description:String {
        switch self {
        case .NotStarted: return "NotStarted"
        case .Ready: return "Ready"
        case .Await: return "Await"
        case .Blocked: return "Blocked"
        case .Completed: return "Completed"
        case .ForceStop: return "ForceStop"
        }
    }
}



/// The action controller is responsible for executing action lists
/// Actions can be added to the controller and once started, the
/// controller will begin running all the actions in the action list.
/// Controller exits when either all actions have run, or if any action
/// in the action list blocks.
class EntityActionController {
    
    var name:String = "EntityActionController"
    
    /// the action list
    var steps = [EntityAction]()
    
    /// the world component
    var world:WorldMapper!
    
    /// target action invoked when controller starts
    var startHandler:TargetAction?
    
    /// target action invoked when controller completes
    var completionHandler:TargetAction?
    
    /// index of the currently running action
    var runningActionIndex = -1
    
    /// the state of the action controller
    let _state = Locked<Int>(ActionControllerState.NotStarted.rawValue)

    
    init(world:WorldMapper) {
        self.world = world
        //self.state = ActionControllerState.NotStarted
    }
    
    /// adds an action to the end of the
    /// action queue
    func add(action:EntityAction) {
        action.controller = self
        self.steps.append(action)
    }
    
    /// inserts an action to the start
    /// of the non-completed action queue
    func insert(action:EntityAction) {
        action.controller = self
        self.steps.insert(action, atIndex: runningActionIndex+1)
    }
    
    /// inserts an action list to the start
    /// of the non-completed action queue
    /// actions are inserted in reverse order
    /// so that they get added properly in sequence
    func insert(actions:[EntityAction]) {
        var i = actions.count-1
        while i >= 0 {
            insert(actions[i])
            i--
        }
    }
    
    func begin() { startHandler?.performAction() }
    
    func end() {
        completionHandler?.performAction()
    }
    
    /// a re-entrantable start implementation
    func run() {
        self.begin()
        runningActionIndex = 0
        _state.set(ActionControllerState.Ready.rawValue)
        continueRun()
    }
    
    
    /// force a stop to the controller
    /// if it is running
    func stop() {
        if _state.value == ActionControllerState.Ready.rawValue || _state.value == ActionControllerState.Await.rawValue {
            _state.set(ActionControllerState.ForceStop.rawValue)
            end()
        }
    }

    /// a better "try as much as possible to be iterative" version
    /// of the action controller
    func continueRun() {
        
        
        // as long as we are not blocked by following actions,
        // continue to run actions in sequence, and if we exhausted all actions
        // mark state as completed
        while _state.value == ActionControllerState.Ready.rawValue && runningActionIndex < self.steps.count {
            let step = self.steps[runningActionIndex]
            _state.set(runAction(step).rawValue)
        }
        
        // did we finish all actions? (...even if we blocked on the very last one)
        if runningActionIndex >= self.steps.count && _state.value != ActionControllerState.ForceStop.rawValue {
            _state.set(ActionControllerState.Completed.rawValue)
            //println("********** STATE SET TO \(state) **********")
        }
        
        // at this point, if we have completed all actions,
        // or were blocked in the process, then finish execution
        if processingComplete {
            self.end()
        }
    }
    
    
    /// runs the action
    func runAction(action:EntityAction) -> ActionControllerState {
        debug_print("CONTROLLER: \(name).\(action.description)" )
        
        /// execute the first part of the action
        /// by running the perform() call
        let skAction = action.perform()
        
        if skAction != nil {
            
            /// run the SKAction on the entities node
            /// if we need to wait for completion
            /// run it via the completion handler, else
            /// just run it and proceed with the next action

            let sprite = world.sprite.get(action.entity)
            
            if action.shouldWaitForActionCompletion {
                sprite.rootNode.runAction(skAction!) {
                    self.actionFinished(action)
                }
                return .Await
            }
            else {
                sprite.rootNode.runAction(skAction!)
                runningActionIndex++
                return .Ready
            }
            
            
        }
            // we are running a simple task
            // check if we blocked, or proceed to the next
            // action
        else {
            if !action.isBlocking {
                runningActionIndex++
                return .Ready
            } else {
                return .Blocked
            }
        }
    }
    
    
    /// completion handler for when an SKAction based
    /// action completes
    func actionFinished(action:EntityAction) {
        if _state.value == ActionControllerState.ForceStop.rawValue {
            self.end()
            return
        }
        if action.isBlocking {
            _state.set(ActionControllerState.Blocked.rawValue)
            self.end()
        } else {
            runningActionIndex++
            _state.set(ActionControllerState.Ready.rawValue)
            continueRun()
        }
    }
    
    

    func update() {
        
        //debug_print("CONTROLLER: \(name).\(_state.value)) - Run[ \(runningActionIndex+1) of \(steps.count) ]" )
        
        if _state.value == ActionControllerState.NotStarted.rawValue {
            begin()
            runningActionIndex = 0
            _state.set(ActionControllerState.Ready.rawValue)
        }
            
        else if _state.value == ActionControllerState.Ready.rawValue {
            
            if runningActionIndex < steps.count {
                let action = steps[runningActionIndex]
                
                debug_print("CONTROLLER: \(name).\(action.description)" )
                let skAction = action.perform()
                
                if skAction != nil {
                    if action.shouldWaitForActionCompletion {
                        let sprite = world.sprite.get(action.entity)
                        sprite.node.runAction(skAction!) {
                            self.onSKActionCompleted(action)
                        }
                        _state.set(ActionControllerState.Await.rawValue)
                    } else {
                        if action.isBlocking {
                            _state.set(ActionControllerState.Blocked.rawValue)
                        } else {
                            runningActionIndex++
                            _state.set(ActionControllerState.Ready.rawValue)
                        }
                    }
                } else {
                    if action.isBlocking {
                        _state.set(ActionControllerState.Blocked.rawValue)
                    } else {
                        runningActionIndex++
                        _state.set(ActionControllerState.Ready.rawValue)
                    }
                }
            }
            
            if runningActionIndex >= self.steps.count && _state.value != ActionControllerState.ForceStop.rawValue {
                _state.set(ActionControllerState.Completed.rawValue)
            }
            
            if processingComplete {
                end()
            }
        }
    }
    
    var processingComplete:Bool {
        let currentState = _state.value
        return  currentState == ActionControllerState.Completed.rawValue ||
                currentState == ActionControllerState.Blocked.rawValue ||
                currentState == ActionControllerState.ForceStop.rawValue
    }
    
    func onSKActionCompleted(action:EntityAction) {
        if _state.value == ActionControllerState.ForceStop.rawValue {
            self.end()
        }
        if action.isBlocking {
            _state.set(ActionControllerState.Blocked.rawValue)
            self.end()
        } else {
            runningActionIndex++
            _state.set(ActionControllerState.Ready.rawValue)
        }
    }
    
}


class Locked<T> {
    private var item:T
    private var gate = NSLock()
    init(_ item:T) {
        self.item = item
    }
    func set(value:T) {
        gate.lock()
        self.item = value
        gate.unlock()
    }
    var value:T {
        gate.lock()
        let value = self.item
        gate.unlock()
        return value
    }
}