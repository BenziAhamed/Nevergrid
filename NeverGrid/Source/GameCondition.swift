//
//  WinningCondition.swift
//  OnGettingThere
//
//  Created by Benzi on 01/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation



// a game condition can have a criterion/role
// which decides if it contributes to a win or lose situation
// to win, all conditions that have a winning criterion should be met
// to lose, any one condition tha has a losing criteria should be met

enum GameConditionRole : CustomStringConvertible {
    case Win
    case Lose
    
    var description: String { get {
            switch(self) {
                case .Win: return "win"
            	case .Lose: return "lose"
            }
        }
    }
}


class GameCondition : CustomStringConvertible {
    var role:GameConditionRole!
    var reason:GameOverReason!
    var met = false
    var target = 0
    init() {} 
    func update(world:WorldMapper) {}
    var description: String { get { return "" } }
}

class CollectGoalsCondition : GameCondition {

    override init() {
        super.init()
        role = GameConditionRole.Win
        reason = GameOverReason(.AllCoinsCollected)
    }
    
    override func update(world: WorldMapper) {
        met = (world.state.coinsCollected == target)
    }
    
    override var description: String { get { return "must collect \(target) coins" } }
}

class MinimumMovesCondition : GameCondition {
    
    override init() {
        super.init()
        role = GameConditionRole.Lose
        reason = GameOverReason(.RanOutOfMoves)
    }

    override func update(world: WorldMapper) {
        met = (target-world.state.movesMade==1)
    }
    
    override var description: String { get { return "must complete in \(target) moves" } }
}


class GameConditionFactory {
    
    class func generateConditions(world:WorldMapper) -> [GameCondition] {
        var conditions = [GameCondition]()
        var goalConditionAdded = false
        for (name,value) in world.level.conditions {

            // goals
            if name == "goals" {
                let c = CollectGoalsCondition()
                if value == "all" {
                    c.target = world.goal.entities().count
                } else {
                    c.target = NSString(string: value).integerValue
                }
                world.state.targetCoins = c.target
                conditions.append(c)
                goalConditionAdded = true
            }
            
            
            // moves
            else if name == "moves" {
                let c = MinimumMovesCondition()
                c.target = NSString(string: value).integerValue
                world.state.targetMoves = c.target
                conditions.append(c)
            }
        }
        
        // you must always have some sort of goal condition
        if conditions.count == 0 || !goalConditionAdded {
            let c = CollectGoalsCondition()
            c.target = world.goal.entities().count
            world.state.targetCoins = c.target
            conditions.append(c)
        }
        
        return conditions
    }
}

