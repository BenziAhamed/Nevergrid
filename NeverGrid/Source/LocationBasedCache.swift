//
//  LocationBasedCache.swift
//  OnGettingThere
//
//  Created by Benzi on 21/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class LocationBasedCache<T> {
    var cache = [Int:[Int:T]]()
    
    
    func clear() {
        cache.removeAll(keepCapacity: true)
    }
    
    
    func clear(location:LocationComponent) {
        self[location.column, location.row] = nil
    }
    
    func set(location:LocationComponent, item:T) {
        self[location.column, location.row] = item
    }
    
    func get(location:LocationComponent) -> T? {
        return self[location.column, location.row]
    }
    
    subscript (column:Int, row:Int) -> T? {
        get {
            if let rowItems = cache[column] {
                return rowItems[row]
            }
            return nil
        }
        set(newValue) {
            if cache[column] == nil {
                cache[column] = [Int:T]()
            }
            var rowItems = cache[column]!
            rowItems[row] = newValue
            cache[column] = rowItems
        }
    }
}