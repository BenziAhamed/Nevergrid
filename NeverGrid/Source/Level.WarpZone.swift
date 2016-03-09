//
//  Level.zoneZone.swift
//  MrGreen
//
//  Created by Benzi on 23/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

/// extensions to support level zoneing
extension Level {
    
    /// returns an array of accumulated zone zones per zone level
    /// configured for this level
    func calculateZoneBounds() -> [ZoneBounds] {
        
        
        // first we calculate the individual zone level bounds
        // then this will be acculumated in order to get the
        // effective zone zone bounds for a given zone level
        // the zone zone bounds is used to calculate the screen
        // rect that covers all cells on screen for a given zone
        // level.
        // as we collect zone keys that start showing up newer sections
        // of the grid, we will centre the camera onto the rect of
        // the effective zone zone rect bounds. This is taken care
        // by the camera system
        
        var zoneBounds = [UInt:ZoneBounds]()
        for c in 0..<columns {
            for r in 0..<rows {
                
                let cell = cells[c,r]!
                
                if cell.type == CellType.Block {
                    continue
                }
                
                //println(cell)
                
                let currentZone = cell.zone
                
                if zoneBounds[currentZone] == nil {
                    zoneBounds[currentZone] = ZoneBounds(zone: currentZone)
                }
                
                let b = zoneBounds[currentZone]!
                
                //print("<c,r>=(\(c),\(r)) \(b) --> ")
                
                if c < b.start.column {
                    b.start.column = c
                }
                else if c > b.end.column {
                    b.end.column = c
                }
                
                if r < b.start.row {
                    b.start.row = r
                }
                else if r > b.end.row {
                    b.end.row = r
                }
                
                //println("\(b)")
            }
        }
        
        
        var combinedZoneBounds = [ZoneBounds]()
        
        for (zone, bounds) in zoneBounds {
            bounds.fixSingleBlock()
            combinedZoneBounds.append(bounds)
            
            //println(bounds)
        }

        // ensure that bounds are ordered based on zone index
        return combinedZoneBounds.sort(sortBounds)
    }
}

func sortBounds(a:ZoneBounds, b:ZoneBounds) -> Bool {
    return a.zone < b.zone
}