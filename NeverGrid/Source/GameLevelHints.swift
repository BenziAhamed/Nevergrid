//
//  GameLevelHints.swift
//  NeverGrid
//
//  Created by Benzi on 15/10/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation


class GameLevelHints {
    
    // dictionary of level hints
    private var hints = [String:[String]]()
    
    init() {
        let hintSet = NSDictionary(contentsOfFile: DataStore.gameLevelHints)!
        for key in hintSet.allKeys {
            hints[key as! String] = hintSet.objectForKey(key) as? [String]
        }
    }
    
    func hasHints(level:LevelItem) -> Bool {
        if let l = hints[level.name as String] {
            return true
        }
        return false
    }
    
    func getHints(level:LevelItem) -> [String] {
        return hints[level.name as String]!
    }
    
    // singleton pattern
    class var sharedInstance: GameLevelHints {
        struct Singleton {
            static let instance = GameLevelHints()
        }
        return Singleton.instance
    }
    
}