//
//  ColorRYB.swift
//  MrGreen
//
//  Created by Benzi on 07/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

// http://web.siat.ac.cn/~baoquan/papers/ryb_TR.pdf

import Foundation
import UIKit

struct ColorRYB {
    let red:CGFloat
    let yellow:CGFloat
    let blue:CGFloat
    
    
    func toRGB() -> UIColor {
        
        var x0:CGFloat, x1:CGFloat, x2:CGFloat, x3:CGFloat, y0:CGFloat, y1:CGFloat
        //red
        x0 = cubic(blue, 1.0, 0.163)
        x1 = cubic(blue, 1.0, 0.0)
        x2 = cubic(blue, 1.0, 0.5)
        x3 = cubic(blue, 1.0, 0.2)
        y0 = cubic(yellow, x0, x1)
        y1 = cubic(yellow, x2, x3)
        let oR = cubic(red, y0, y1)
        //green
        x0 = cubic(blue, 1.0, 0.373)
        x1 = cubic(blue, 1.0, 0.66)
        x2 = cubic(blue, 0.0, 0.0)
        x3 = cubic(blue, 0.5, 0.094)
        y0 = cubic(yellow, x0, x1)
        y1 = cubic(yellow, x2, x3)
        let oG = cubic(red, y0, y1)
        //blue
        x0 = cubic(blue, 1.0, 0.6)
        x1 = cubic(blue, 0.0, 0.2)
        x2 = cubic(blue, 0.0, 0.5)
        x3 = cubic(blue, 0.0, 0.0)
        y0 = cubic(yellow, x0, x1)
        y1 = cubic(yellow, x2, x3)
        let oB = cubic(red, y0, y1)

        let color = UIColor(red: oR, green: oG, blue: oB, alpha: 1.0)
        return color
    }
    
    func cubic(t:CGFloat, _ a:CGFloat, _ b:CGFloat) -> CGFloat {
        let weight = t*t*(3.0-2.0*t)
        return a + weight * (b - a)
    }
}