//
//  LevelData.swift
//  gettingthere
//
//  Created by Benzi on 02/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation


// This class provides an interface to look up and list all
// levels that are defined in the LevelData.plist file
class GameLevelData {

    // will hold a list of all identified levels
    var chapters = [ChapterItem]()
    var totalLevels:Int = 0
    
    init() {
       loadLevelList()
    }
    
    
    
    // this popultaes the levels array with the contents of
    // the level file
    func loadLevelList() {
        
        // The level data .plist file contains the structure of levels
        // organized by chapter.
        // We will load the level list based the contents of that file
        // not the actual file system
        let data = NSArray(contentsOfFile: DataStore.gameLevelData)!
        
        let completedLevels = LevelProgressSystem.getGameProgressData()
        
        chapters.removeAll(keepCapacity: true)
        var levelNumber = 1
        
        // for each chapter
        for c in 0..<data.count {
            let chapter = data[c] as! NSDictionary
            let chapterName = chapter["ChapterName"] as! NSString
            
            // should this chapter be ignored?
            if chapterName.hasPrefix("!") { continue }
            
            let displayName = chapter["DisplayName"] as! NSString
            let levels = chapter["Levels"] as! NSArray
            
            let chapterItem = ChapterItem(name: String(chapterName), display: String(displayName))
            
            // for each level
            for l in 0..<levels.count {
                let levelName = levels[l] as! NSString
                
                // make sure we ignore comments
                if !levelName.hasPrefix("!") {
                    let levelItem = LevelItem(
                        number: levelNumber,
                        chapter: chapterItem,
                        name: levelName.stringByReplacingOccurrencesOfString(".tmx", withString: "")
                    )
                    levelNumber++
                    levelItem.isCompleted = (completedLevels[levelItem.levelKey] != nil)
                    chapterItem.levels.append(levelItem)
                }
                
            }
            
            
            chapters.append(chapterItem)
        }
        
        totalLevels = levelNumber-1
    }
    
    // singleton pattern
    class var shared: GameLevelData {
        struct Singleton {
            static let instance = GameLevelData()
        }
        return Singleton.instance
    }
    
    
}


class ChapterItem {
    var name:String
    var displayName:String
    var levels = [LevelItem]()
    
    init(name:String, display:String) {
        self.name = name
        self.displayName = display
    }
    
    var isLastChapter:Bool {
        return name == GameLevelData.shared.chapters.last?.name
    }
    
    var isFirstChapter:Bool {
        return name == GameLevelData.shared.chapters.first?.name
    }
    
}



// This is a basic level item entry that is to be found
// in the LevelData.plist file
// This is used to represent a logical level item as defined
// by its chapter name and level name
class LevelItem {

    weak var chapter:ChapterItem?
    let name:NSString
    let number:Int
    var isCompleted:Bool = false
    
    var levelKey:NSString {
        return "\(chapter!.name)--\(self.name)"
    }
    
    var url:NSURL! {
        return NSBundle.mainBundle().URLForResource(name as String, withExtension: ".tmx", subdirectory: "/Levels/\(chapter!.name)")
    }
    
    var isLastLevelInChapter:Bool {
        return levelKey == chapter?.levels.last?.levelKey
    }
    
    var isFirstLevelInChapter:Bool {
        return levelKey == chapter?.levels.first?.levelKey
    }
    
    func shouldDisplayChapterUnlocked() -> Bool {
        if chapter!.isLastChapter { return false }
        if chapter!.isFirstChapter { return false }
        if isFirstLevelInChapter {
            let settings = GameSettings()
            if settings.chaptersUnlocked[chapter!.name] == nil {
                settings.chaptersUnlocked[chapter!.name] = true
                settings.save()
                return true
            }
        }
        return false
    }
    
    init(number:Int, chapter:ChapterItem, name:String) {
        self.number = number
        self.name = name
        self.chapter = chapter
    }

}