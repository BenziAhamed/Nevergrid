//
//  Stack.swift
//  MrGreen
//
//  Created by Benzi on 08/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class Stack<T> {
    var items = [T]()
    func push(item:T) { items.append(item) }
    func pop() -> T { return items.removeAtIndex(items.count-1) }
    func top() -> T { return items[items.count-1] }
}