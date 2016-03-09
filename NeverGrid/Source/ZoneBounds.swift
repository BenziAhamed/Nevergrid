//
//  ZoneBounds.swift
//  MrGreen
//
//  Created by Benzi on 23/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

/// Zone bounds is the rectangle that contains the
/// grid cells for a given zone level inside the game
struct ZoneBounds : CustomStringConvertible {
    var zone:UInt
    var start:LocationComponent
    var end:LocationComponent
    
    init(zone:UInt) {
        self.zone = zone
        self.start = LocationComponent(row: Int.max, column: Int.max)
        self.end = LocationComponent(row: -1, column: -1)
    }
    
    func fixSingleBlock() {
        if end.column == -1 && end.row == -1 {
            end.column = start.column
            end.row = start.row
        }
    }
    
    func getRectBounds(gs:GridSystem) -> CGRect {
        let blCell = gs.getCellPosition(row: end.row, column: start.column)
        let width = end.column - start.column + 1
        let height = end.row - start.row + 1
        return CGRectMake(
            blCell.x,
            blCell.y - 0.125*gs.sideLength,
            gs.sideLength * CGFloat(width),
            0.125*gs.sideLength + gs.sideLength * CGFloat(height)
        )
    }
    
    var description:String {
        return "zone:\(zone) - start:\(start), end:\(end)"
    }
    
    func combine(with:ZoneBounds) -> ZoneBounds {
        let target = ZoneBounds(zone: with.zone)
        target.start.column = min(self.start.column, with.start.column)
        target.start.row = min(self.start.row, with.start.row)
        target.end.column = max(self.end.column, with.end.column)
        target.end.row = max(self.end.row, with.end.row)
        return target
    }
    
    
    /// returns true if we overlap with the provided zone
    func overlaps(with:ZoneBounds) -> Bool {
        
        if self.start.row - with.end.row > 1 || with.start.row - self.end.row > 1 { return false }
        if self.start.column - with.end.column > 1 || with.start.column - self.end.column > 1 { return false }
        
        return true
    }
}