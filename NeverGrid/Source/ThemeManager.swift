//
//  ThemeManager.swift
//  MrGreen
//
//  Created by Benzi on 29/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class ThemeSettings {
    var enableShadows:Bool = false
    var textureExtension:String = ""
    var blendMode:SKBlendMode = SKBlendMode.Screen
    var backgroundTexture:String = "" // TODO: remove
    var mainmenuImage:String = ""
    var gameplayImage:String = ""
    var cellSpacing:CGFloat = 0.0
    var cellExtends:CGFloat = 0.125 // in % of total size
    var cellColorBlendFactor:CGFloat = 1.0
    var colorizeCells:Bool = true
    var cellColors:[UIColor]!
    var wallColor:UIColor!
    var titleColor:UIColor = UIColor.whiteColor()
    var ignoreBlocks:Bool = false
    
    init()
    {
    }
}




class ThemeManager {
    
    var settings:ThemeSettings
    
    init(_ settings:ThemeSettings) {
        
//        var settings = ThemeSettings()
//        
//        settings.mainmenuImage = "background_darkblue"
//        settings.gameplayImage = "background_darkblue"
//        
//        settings.wallColor = UIColor(red: 74, green: 74, blue: 74)
//        
//        settings.cellColors = [
//            UIColor.whiteColor()
//            ,UIColor.whiteColor().colorWithShadow(0.05)
//        ]
//        
//        settings.blendMode = SKBlendMode.Alpha
//        settings.textureExtension = "_noextends"
//        
//        settings.cellSpacing = factor(forPhone: -0.5, forPad: -1.0)
//        
//        settings.enableShadows = false
        
        self.settings = settings
    }
    
    func getCellColor(column column:Int, row:Int) -> UIColor {
        return settings.cellColors[(column+row)%settings.cellColors.count]
    }
    
    func getBlockColor(column column:Int, row:Int) -> UIColor {
        return getCellColor(column: column+1, row: row)
    }
    
    func getWallColor() -> UIColor {
        return settings.wallColor
    }
    
    func getTextureName(texture:String) -> String {
        return texture + settings.textureExtension
    }
    
    func getBackgroundTexture() -> String {
        return settings.backgroundTexture
    }
    
    class func trueblue() -> ThemeManager {
        let settings = ThemeSettings()
        
        settings.mainmenuImage = "background_darkblue"
        //let time = any(["morning","midday","evening","twilight","night"])
        settings.gameplayImage = "background_midday_sky"
        
        settings.wallColor = UIColor(red: 74, green: 74, blue: 74)
        
        settings.cellColors = [
            UIColor.whiteColor()
            ,UIColor.whiteColor().colorWithShadow(0.05)
        ]
        
        settings.blendMode = SKBlendMode.Alpha
        settings.textureExtension = "_noextends"
        
        settings.cellSpacing = factor(forPhone: -0.5, forPad: -1.0)
        
        settings.enableShadows = false
        
        return ThemeManager(settings)
    }
    
    
    class func defaultTheme() -> ThemeManager {
        //let themes:[()->ThemeManager] = [ThemeManager.trueblue,ThemeManager.lightBlue,ThemeManager.nightSky,ThemeManager.brownSky]
        //return any(themes)()
        return trueblue()
    }
}


//    class func lightBlue() -> ThemeManager {
//        var settings = ThemeSettings()
//
//        settings.mainmenuImage = "background_darkblue"
//        //let time = any(["morning","midday","evening","twilight","night"])
//        settings.gameplayImage = "background_morning_sky"
//
//        settings.wallColor = UIColor(red: 74, green: 74, blue: 74)
//
//        settings.cellColors = [
//            UIColor.whiteColor()
//            ,UIColor.whiteColor().colorWithShadow(0.05)
//        ]
//
//
//        settings.blendMode = SKBlendMode.Alpha
//        settings.textureExtension = "_noextends"
//
//        settings.cellSpacing = factor(forPhone: -0.5, forPad: -1.0)
//
//        settings.enableShadows = false
//
//        return ThemeManager(settings)
//    }
//
//    class func nightSky() -> ThemeManager {
//        var settings = ThemeSettings()
//
//        settings.mainmenuImage = "background_darkblue"
//        //let time = any(["morning","midday","evening","twilight","night"])
//        settings.gameplayImage = "background_night_sky"
//
//        settings.wallColor = UIColor(red: 74, green: 74, blue: 74)
//
//        settings.cellColors = [
//            UIColor.whiteColor()
//            ,UIColor.whiteColor().colorWithShadow(0.05)
//        ]
//
//        settings.blendMode = SKBlendMode.Alpha
//        settings.textureExtension = "_noextends"
//
//        settings.cellSpacing = factor(forPhone: -0.5, forPad: -1.0)
//
//        settings.enableShadows = false
//
//        return ThemeManager(settings)
//    }
//
//    class func brownSky() -> ThemeManager {
//        var settings = ThemeSettings()
//
//        settings.mainmenuImage = "background_darkblue"
//        //let time = any(["morning","midday","evening","twilight","night"])
//        settings.gameplayImage = "background_brown_sky"
//
//        settings.wallColor = UIColor(red: 74, green: 74, blue: 74)
//
//        settings.cellColors = [
//            UIColor.whiteColor()
//            ,UIColor.whiteColor().colorWithShadow(0.05)
//        ]
//
//
//        settings.blendMode = SKBlendMode.Alpha
//        settings.textureExtension = "_noextends"
//
//        settings.cellSpacing = factor(forPhone: -0.5, forPad: -1.0)
//
//        settings.enableShadows = false
//
//        return ThemeManager(settings)
//    }
