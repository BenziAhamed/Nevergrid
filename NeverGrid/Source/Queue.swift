//
//  Queue.swift
//  NeverGrid
//
//  Created by Benzi on 25/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

// a very simple queue
class Queue<T> {
    var items = [T]()
    init() {}
    func push(item:T) { items.append(item) }
    func pop() -> T { return items.removeAtIndex(0) }
    var count:Int { return items.count }
    func clear() { items.removeAll(keepCapacity: false) }
}

class SyncQueue<T> : Queue<T> {
    private var gate = NSLock()
    override func push(item:T) {
        gate.lock()
        super.push(item)
        gate.unlock()
    }
    override func pop() -> T {
        gate.lock()
        let item = super.pop()
        gate.unlock()
        return item
    }
}