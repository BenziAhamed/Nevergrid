//
//  Categories.swift
//  gameninja
//
//  Created by Benzi on 19/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


// MARK: Components ------------------------------------------

enum ComponentType {
    case Sprite
    case Location
    case Player //entity
    case Enemy //entity
    case Goal //entity
    case Powerup //entity
    case Cell
    case Portal
    case Wall
    case Freeze
    case Slide
    case ZoneKey
    case Collectable
}

class Component {
    var type:ComponentType
    init(type:ComponentType) { self.type = type }
}

class SpriteComponent : Component {
    var node:SKSpriteNode
    var rootNode:SKNode!
    init(node:SKSpriteNode) {
        self.node = node
        self.rootNode = node
        super.init(type: ComponentType.Sprite)
    }
}

class LocationComponent : Component, Equatable, CustomStringConvertible {
    var previousRow:Int = -1
    var row:Int {
        willSet { previousRow = row }
    }
    
    var previousColumn:Int = -1
    var column:Int {
        willSet { previousColumn = column  }
    }
    
    var lastMove:UInt {
        return getPossibleMove(self, end: LocationComponent(row: previousRow, column: previousColumn))
    }
    
    init(row:Int, column:Int){
        self.row = row
        self.column = column
        super.init(type: ComponentType.Location)
    }
    
    var description:String {
        return "(\(self.column),\(self.row))"
    }
    
}

extension LocationComponent {
    func clone() -> LocationComponent {
        return LocationComponent(row: self.row, column: self.column)
    }
    
    func previous() -> LocationComponent {
        return LocationComponent(row: self.previousRow, column: self.previousColumn)
    }
    
    func hasChanged() -> Bool {
        return previousRow != row || previousColumn != column
    }
    
    func stayInPlace() {
        self.row = self.row + 1 - 1
        self.column = self.column + 1 - 1
    }
}

extension LocationComponent {
    func offsetRow(amount:Int) -> LocationComponent {
        return LocationComponent(row: self.row+amount, column: self.column)
    }
    
    func offsetColumn(amount:Int) -> LocationComponent {
        return LocationComponent(row: self.row, column: self.column+amount)
    }
    
    func offset(row row:Int, column:Int) -> LocationComponent {
        return LocationComponent(row: self.row+row, column: self.column+column)
    }
}

extension LocationComponent {
    var neighbourTop:LocationComponent { return self.offset(row: -1, column: 0) }
    var neighbourTopLeft:LocationComponent { return self.offset(row: -1, column: -1) }
    var neighbourTopRight:LocationComponent { return self.offset(row: -1, column: +1) }
    var neighbourLeft:LocationComponent { return self.offset(row: 0, column: -1) }
    var neighbourRight:LocationComponent { return self.offset(row: 0, column: +1) }
    var neighbourBottom:LocationComponent { return self.offset(row: +1, column: 0) }
    var neighbourBottomLeft:LocationComponent { return self.offset(row: +1, column: -1) }
    var neighbourBottomRight:LocationComponent { return self.offset(row: +1, column: +1) }
}

// gives the manhattan distance between two locations
func distance(a:LocationComponent, b:LocationComponent) -> Int {
    return abs(a.row - b.row) + abs(a.column - b.column)
}

func getPossibleMove(start:LocationComponent, end:LocationComponent) -> UInt {
    if distance(start, b: end) == 1 {
        if start.row == end.row {
            if start.column > end.column {
                return Direction.Left
            } else {
                return Direction.Right
            }
        } else {
            if start.row > end.row {
                return Direction.Up
            } else {
                return Direction.Down
            }
        }
    }
    return Direction.None
}


func ==(lhs:LocationComponent, rhs:LocationComponent)->Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

class PlayerComponent : Component {
    var teleportedInLastMove:Bool = false
    var emotion = Emotion.Happy
    init() {
        super.init(type: ComponentType.Player)
    }
}

enum EnemyType : CustomStringConvertible {
    case OneStep
    case TwoStep
    case Cloner
    case SliderLeftRight
    case SliderUpDown
    case Monster
    case Destroyer
    case Robot
    
    var description:String {
        switch self {
        case .OneStep: return "OneStep"
        case .TwoStep: return "TwoStep"
        case .Cloner: return "Cloner"
        case .SliderLeftRight: return "SliderLeftRight"
        case .SliderUpDown: return "SliderUpDown"
        case .Monster: return "Monster"
        case .Destroyer: return "Destroyer"
        case .Robot: return "Robot"
        default: return "Unknown"
        }
    }
}


enum Emotion {
    case Happy
    case Sad
    case Surprised
    case Elated
    case HalfBlink
    case FullBlink
    case Angry
    case Rage
    case Screaming
    case Contempt
    case Uff
}

class EnemyComponent : Component {
    
    struct ClonerSettings {
        static let StepsToWaitUntilCloneAction = 5
    }
    
    var enemyType:EnemyType
    var alive:Bool = true
    var enabled:Bool = false
    var bootedUp:Bool = false
    var skipTurns:Int = 0
    var clonesCreated = 0
    var stepsUntilNextClone = ClonerSettings.StepsToWaitUntilCloneAction
    init(type:EnemyType) {
        self.enemyType = type
        super.init(type: ComponentType.Enemy)
    }
}

class CollectableComponent : Component {
    init() {
        super.init(type: ComponentType.Collectable)
    }
}

class GoalComponent : Component {
    init() {
        super.init(type: ComponentType.Goal)
    }
}

class ZoneKeyComponent : Component {
    var zoneID:UInt = 0
    
    init(zoneID:UInt) {
        self.zoneID = zoneID
        super.init(type: ComponentType.ZoneKey)
    }
}


enum CellType : CustomStringConvertible {
    case Normal
    case Fluffy
    case Falling
    case Block
    
    var description:String {
        switch self {
            case .Normal: return "normal"
            case .Fluffy: return "fluffy"
            case .Falling: return "falling"
            case .Block: return "block"
        }
    }
}

class CellComponent : Component {
    var cellType:CellType
    var fallen:Bool = false
    init(type: CellType) {
        self.cellType = type
        super.init(type: ComponentType.Cell)
    }
}

enum PortalColor {
    case Orange
    case Blue
}

class PortalComponent : Component {
    var destination:LocationComponent
    var color:PortalColor
    var enabled:Bool = false
    
    init(destination:LocationComponent, color:PortalColor) {
        self.destination = destination
        self.color = color
        super.init(type: ComponentType.Portal)
    }
}




class FreezeComponent : Component {
    var duration:PowerupDuration
    init(duration:PowerupDuration) {
        self.duration = duration
        super.init(type: ComponentType.Freeze)
    }
}

class SlideComponent : Component {
    var duration:PowerupDuration
    init(duration:PowerupDuration) {
        self.duration = duration
        super.init(type: ComponentType.Slide)
    }
}


enum PowerupType {
    case Slide
    case Freeze
}

enum PowerupDuration {
    case TurnBased(Int)
    case Infinite
}

class PowerupComponent : Component {
    var powerupType:PowerupType
    var duration:PowerupDuration
    init(type:PowerupType, duration:PowerupDuration) {
        self.powerupType = type
        self.duration = duration
        super.init(type: ComponentType.Powerup)
    }
}


