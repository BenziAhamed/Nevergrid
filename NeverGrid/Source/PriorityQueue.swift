//
//  PriorityQueue.swift
//  MrGreen
//
//  Created by Benzi on 03/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

struct PriorityQueueNode<T> {
    var item:T
    var priority:Int
}

class PriorityQueue<T> {
    
    var q = [PriorityQueueNode<T>]()
    var count:Int {
        return q.count
    }
    
    func put(item:T, priority:Int) {
        let node = PriorityQueueNode(item: item, priority: priority)
        if q.count == 0 {
            q.append(node)
        } else {
            var insertIndex = 0
            while insertIndex < count && q[insertIndex].priority <= priority {
                insertIndex++
            }
            
            if insertIndex < q.count {
                q.insert(node, atIndex: insertIndex)
            } else {
                q.append(node)
            }
        }
    }
    
    func get() -> T? {
        if q.count == 0 {
            return nil
        }
        else {
            return q.removeAtIndex(0).item
        }
    }
    
}