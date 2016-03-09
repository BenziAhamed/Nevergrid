//
//  TargetAction.swift
//  OnGettingThere
//
//  Created by Benzi on 06/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//
// http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/

import Foundation

protocol TargetAction {
    func performAction()
}


class Callback<T: AnyObject> : TargetAction {
    weak var target: T?
    let action: (T) -> () -> ()
    
    init(_ target:T, _ action:(T) -> () -> ()) {
        self.target = target
        self.action = action
    }
    
    func performAction() -> () {
        if let t = target {
            action(t)()
        }
    }
}

//struct EventArgs { }
//
//protocol EventHandler {
//    func handleEvent(sender:AnyObject, args:EventArgs)
//}
//
//struct EventHandlerCallback<T:AnyObject> : EventHandler {
//    weak var target: T?
//    let action: (T) -> (AnyObject,EventArgs) -> ()
//    
//    init(_ target:T, _ action:(T) -> (AnyObject,EventArgs) -> ()) {
//        self.target = target
//        self.action = action
//    }
//    
//    func handleEvent(sender:AnyObject, args:EventArgs) -> () {
//        if let t = target {
//            action(t)(sender, args)
//        }
//    }
//}

