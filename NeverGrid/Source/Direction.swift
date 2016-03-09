//
//  Direction.swift
//  MrGreen
//
//  Created by Benzi on 11/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

struct Direction {
    static let None:UInt = 0
    static let Right:UInt = 1
    static let Left:UInt = 2
    static let Up:UInt = 4
    static let Down:UInt = 8
    static let All:UInt = 15
    
//    static let Locator = [
//        Up: (0,1,1,1),
//        Down: (0,0,1,0),
//        Right: (1,1,1,0),
//        Left: (0,0,0,1)
//    ]
//    
//    static let ShadowGroup = [
//        Up: (Right,Left),
//        Down: (Right,Left),
//        Right: (Up,Down),
//        Left: (Up,Down)
//    ]
    
    static let Opposite = [
        Up:Down,
        Down:Up,
        Left:Right,
        Right:Left
    ]
    
    static let Name = [
        Up:"up",
        Down:"down",
        Left:"left",
        Right:"right",
        None:"none"
    ]
    
    static let AllDirections = [Direction.Up,Direction.Down,Direction.Left,Direction.Right]
    static let UpDown = [Direction.Up,Direction.Down]
    static let LeftRight = [Direction.Left,Direction.Right]
}