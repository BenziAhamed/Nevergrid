//
//  FontSize.swift
//  MrGreen
//
//  Created by Benzi on 08/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

/// font sizes for various texts
struct FontSize {
    static let MainMenuTitle:CGFloat = factor(forPhone: 80, forPad: 132)
    static let MainMenuItems:CGFloat = factor2(forPhone: 30, forPhone3x: 40, forPad: 60.0)
    
    static let GameOverPrimary:CGFloat = factor(forPhone: 35, forPad: 60)
    static let GameOverSecondary:CGFloat = factor(forPhone: 25, forPad: 50)
    
    static let Title:CGFloat = factor(forPhone: 30, forPad: 45)
    static let Subtitle:CGFloat = factor(forPhone: 10, forPad: 22)
    
    static let HudTextNodeTextSize:CGFloat = factor(forPhone: 25, forPad: 45)
    static let HudTextNodeSubtextSize:CGFloat = factor(forPhone: 10, forPad: 20)
    
    static let MenuHudNodeTextSize:CGFloat = factor(forPhone: 18, forPad: 30)
    
    
    static let ChapterNodeTextSize:CGFloat = factor(forPhone: 10, forPad: 25)
    
    static let ChapterNameSize:CGFloat = factor2(forPhone: 35.0, forPhone3x: 45.0, forPad: 65.0)
    static let LevelNumberSize:CGFloat = factor2(forPhone: 25.0, forPhone3x: 40.0, forPad: 50.0)
}