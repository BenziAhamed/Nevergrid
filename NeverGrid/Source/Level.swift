//
//  Test.swift
//  gettingthere
//
//  Created by Benzi on 23/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

enum LevelObjectGroup {
    case None
    case Player
    case Item
    case Enemy
    case Powerup
    case Portal
    case Cell
}

class LevelObject {
    var group = LevelObjectGroup.None
    var type:String!
    var location:LocationComponent!
    var properties = [String:String]()
    
    init() {}
    
    struct Keys {
        static let turns = "turns"
    }
}

enum ZoneBehaviour {
    case Mergeable
    case Standalone
}

class Level {
    var rows:Int = 0
    var columns:Int = 0
    
    var info:LevelItem!
    
    var title:String? = nil
    var conditions = [String:String]()
    var levelObjects = [LevelObject]()
    
    var initialZone:UInt = 0
    var zoneBehaviour:ZoneBehaviour = ZoneBehaviour.Mergeable

    init() {}
    
    func getCellRelativeTo(column column:Int, row:Int, direction:UInt) -> (Int,Int)? {
        switch direction {
        case Direction.Left:
            if column > 0 {
                return (column-1,row)
            }
        case Direction.Down:
            if row < self.rows-1 {
                return (column,row+1)
            }
        case Direction.Up:
            if row > 0 {
                return (column,row-1)
            }
        case Direction.Right:
            if column < self.columns-1 {
                return (column+1,row)
            }
        default:
            break
        }
        return nil
    }
    
    var cells = LocationBasedCache<GridCell>()
}


class GridCell : CustomStringConvertible {
    var walls:UInt = 0
    var cellRoundedness:UInt = 0
    var blockRoundedness:UInt = 0
    var shadows:Int = 0
    var zone:UInt = 0
    var type:CellType = CellType.Block
    var active:Bool = false
    var fallen:Bool = false
    var occupiedByEnemy = false
    var occupiedBy:Entity? = nil {
        didSet {
            if occupiedBy == nil {
                occupiedByEnemy = false
            } else {
                occupiedByEnemy = true
            }
        }
    }
    
    var goal:Entity? = nil
    var powerup:Entity? = nil
    var zoneKey:Entity? = nil
    
    
    let location:LocationComponent = LocationComponent(row: -1, column: -1)
    
    var canCastShadows:Bool {
        return (active && !fallen && type != CellType.Block)
    }
    
    func hasWall(inDirection:UInt) -> Bool {
        return (walls & inDirection) > 0
    }
    
    var description:String {
        return
            "\(location) - zone:\(zone) - active:\(active) - walls:\(walls) - type:\(type) - roundedness[cell:\(cellRoundedness),block:\(blockRoundedness)]"
    }
    
    init() {}
}


extension Level {
    
    func initializeCells() {
        for c in 0..<self.columns {
            for r in 0..<self.rows {
                let cell = GridCell()
                cell.location.row = r
                cell.location.column = c
                cells[c,r] = cell
            }
        }
    }
    
    func activateCells(zone:UInt) {
        for c in 0..<self.columns {
            for r in 0..<self.rows {
                let cell = cells[c,r]!
                if cell.zone == zone {
                    cell.active = true
                }
            }
        }
    }
    
    func getColumnRow(index:Int) -> (Int,Int) {
        let c = index % columns
        let r = index / columns
        return (c,r)
    }
    
    func cellAt(index:Int) -> GridCell {
        let (c,r) = getColumnRow(index)
        return cells[c,r]!
    }
    
    func getNeighbour(cell:GridCell, direction:UInt) -> GridCell? {
        if let (c,r) = getCellRelativeTo(column: cell.location.column, row: cell.location.row, direction: direction) {
            return cells[c,r]
        }
        return nil
    }
    
    func movePossible(location:LocationComponent, direction:UInt) -> Bool {
        if let cell = cells.get(location) {
            return movePossible(cell, direction: direction)
        }
        return false
    }
    
    func movePossible(cell:GridCell, direction:UInt) -> Bool {
        if let neighbour = getNeighbour(cell, direction: direction) {
            let cellAllowed = !cell.hasWall(direction) && cell.active
            let neighbourAllowed = !neighbour.hasWall(Direction.Opposite[direction]!) && neighbour.active
            return cellAllowed && neighbourAllowed
        }
        return false
    }
    
    func isActive(location:LocationComponent) -> Bool {
        return cells.get(location)!.active
    }

}






