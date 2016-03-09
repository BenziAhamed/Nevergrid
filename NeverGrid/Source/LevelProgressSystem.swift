//
//  LevelProgressSystem.swift
//  gettingthere
//
//  Created by Benzi on 02/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation


// game data - contains the progress information
// levelkey: --> String
//      completed: true/false --> Bool
//      moves: -->Int (best moves) when syncing it should be the lower of the two in case of conflict

struct LevelState {
    var completed: Bool
    var moves: Int
    
    // keys used to store level progress information
    struct LevelStateSerializationKeys {
        static let completed = "completed"
        static let moves = "moves"
    }
    
    init(completed: Bool, moves: Int) {
        self.completed = completed
        self.moves = moves
    }
    
    init(dict:NSDictionary) {
        self.completed = dict[LevelStateSerializationKeys.completed] as! Bool
        self.moves = dict[LevelStateSerializationKeys.moves] as! Int
    }
    
    func serialize() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict[LevelStateSerializationKeys.completed] = completed
        dict[LevelStateSerializationKeys.moves] = moves
        return dict
    }
}

class LevelProgressSystem {
    
    class func markLevelCompleted(level:LevelItem, state:LevelState) {
        let data = getGameProgressData()
        data[level.levelKey] = state.serialize()
        saveGameProgressData(data)
        
        for c in GameLevelData.shared.chapters {
            for l in c.levels {
                if l.levelKey == level.levelKey {
                    l.isCompleted = true
                    break
                }
            }
        }
    }
    
    class func getNextLevelItem() -> LevelItem? {
        
        let gameProgress = getGameProgressData()
        let completedLevelKeys = gameProgress.allKeys as! [String]
        let chapters = GameLevelData.shared.chapters
        
        if gameProgress.count == 0 {
            return chapters[0].levels[0]
        } else {
            for chapter in chapters {
                for level in chapter.levels {
                    if gameProgress[level.levelKey] == nil {
                        return level
                    }
                }
            }
        }
        return nil
    }
    
    class func getNextLevel() -> Level {
        let parser = LevelParser(levelItem: getNextLevelItem()!)
        parser.parse()
        return parser.level!
    }
    
    class func getNextLevelInSequence(from:LevelItem) -> Level {
        let parser = LevelParser(levelItem: getNextLevelItemInSequence(from)!)
        parser.parse()
        return parser.level!
    }
    
    
    
    class func isLevelCompleted(levelItem:LevelItem) -> Bool {
        return levelItem.isCompleted
    }

    class func getNextLevelItemInSequence(from:LevelItem) -> LevelItem? {
        let chapters = GameLevelData.shared.chapters
        let nextLevelNumber = from.number + 1
        for chapter in chapters {
            for level in chapter.levels {
                if level.number == nextLevelNumber {
                    return level
                }
            }
        }
        return nil
    }
    
}

extension LevelProgressSystem {
    class func getGameProgressData() -> NSMutableDictionary {
        if !DataStore.fileExists(DataStore.gameProgressPath as String) {
            NSMutableDictionary().writeToFile(DataStore.gameProgressPath as String, atomically: true)
        }
        return NSMutableDictionary(contentsOfFile: DataStore.gameProgressPath as String)!
    }
    
    class func saveGameProgressData(data:NSMutableDictionary) {
        data.writeToFile(DataStore.gameProgressPath as String, atomically: true)
    }
    
    class func reset() {
        
        DataStore.removeFile(DataStore.gameProgressPath as String)
        DataStore.removeFile(DataStore.gameSettingsPath as String)
        
        let chapters = GameLevelData.shared.chapters
        for chapter in chapters {
            for level in chapter.levels {
                level.isCompleted = false
            }
        }
    }


}

struct DataStore {
    
    static let gameProgressPath = DataStore.getFilePath("gameprogress.plist")
    static let gameSettingsPath = DataStore.getFilePath("gamesettings.plist")
    static let gameLevelData = NSBundle.mainBundle().pathForResource("LevelData", ofType: "plist")!
    static let gameLevelHints = NSBundle.mainBundle().pathForResource("LevelHints", ofType: "plist")!
    static let helpMessages = NSBundle.mainBundle().pathForResource("HelpMessages", ofType: "plist")!
    
    static func fileExists(path:String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    static func removeFile(path:String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch _ {
        }
    }
    
    private static func getFilePath(name:String) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsPath = paths[0] as NSString
        let path = documentsPath.stringByAppendingPathComponent(name)
        return path
    }
}

class GameSettings {
    
    private let KEY_INTRO = "introSeen"
    private let KEY_OUTRO = "outroSeen"
    private let KEY_HINTS = "hintsShown"
    private let KEY_MUSIC = "musicEnabled"
    private let KEY_SOUNDS = "soundsEnabled"
    private let KEY_CHAPTER_UNLOCKED = "chaptersUnlocked"
    
    var introSeen:Bool = false
    var outroSeen:Bool = false
    var musicEnabled:Bool = true
    var soundEnabled:Bool = true
    var hintsShown = [Int:Bool]()
    var chaptersUnlocked = [String:Bool]()
    
    init() {
        if DataStore.fileExists(DataStore.gameSettingsPath as String) {
            let d = NSMutableDictionary(contentsOfFile: DataStore.gameSettingsPath as String)!
            
            if let v = d.objectForKey(KEY_INTRO) as? Bool {
                introSeen = v
            }
            if let v = d.objectForKey(KEY_OUTRO) as? Bool {
                outroSeen = v
            }
            
            if let v = d.objectForKey(KEY_MUSIC) as? Bool {
                musicEnabled = v
            }
            if let v = d.objectForKey(KEY_SOUNDS) as? Bool {
                soundEnabled = v
            }
            
            let hints = d.objectForKey(KEY_HINTS) as! NSDictionary
            for key in hints.allKeys {
                hintsShown[NSString(string: key as! String).integerValue] = true
            }
            
            let chapters = d.objectForKey(KEY_CHAPTER_UNLOCKED) as! NSDictionary
            for key in chapters.allKeys {
                chaptersUnlocked[key as! String] = true
            }
        }
    }
    
    func save() {
        let d = NSMutableDictionary()
        
        // KEY_INTRO
        d.setObject(introSeen, forKey: KEY_INTRO)
        
        // KEY_OUTRO
        d.setObject(outroSeen, forKey: KEY_OUTRO)
        
        // KEY_MUSIC
        d.setObject(musicEnabled, forKey: KEY_MUSIC)

        // KEY_SOUNDS
        d.setObject(soundEnabled, forKey: KEY_SOUNDS)

        // KEY_HINTS
        let hints = NSMutableDictionary()
        for (k,v) in hintsShown {
            hints.setObject(true, forKey: "\(k)")
        }
        d.setObject(hints, forKey: KEY_HINTS)
        
        
        // KEY_CHAPTER_UNLOCKED
        let chapters = NSMutableDictionary()
        for (k,v) in chaptersUnlocked {
            chapters.setObject(true, forKey: k)
        }
        d.setObject(chapters, forKey: KEY_CHAPTER_UNLOCKED)
        
        
        d.writeToFile(DataStore.gameSettingsPath as String, atomically: true)
    }
}