//
//  Extensions.swift
//  gettingthere
//
//  Created by Benzi on 27/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit


#if DEBUG
var updateLoopCounter:Int = 0
var lastUpdateLoopCounter:Int = 0
#endif

func debug_print(@autoclosure message : ()->String) {
    #if DEBUG
    if lastUpdateLoopCounter != updateLoopCounter {
        print("-----------------------------------")
        lastUpdateLoopCounter = updateLoopCounter
    }
    print("\(updateLoopCounter): "+message())
    #endif
}


struct Notifications {
    static let Twitter = "NevergridPostTwitterMessage"
    static let Facebook = "NevergridPostFacebookMessage"
}


///// returns true if any element is common between a and b
//func intersects<T:Equatable>(a:[T], b:[T]) -> Bool {
//    for l1 in a {
//        for l2 in b {
//            if l1 == l2 {
//                return true
//            }
//        }
//    }
//    return false
//}

//class Random {
//    class func either<T>(a:T, _ b:T) -> T {
//        return unitRandom() < 0.5 ? a : b
//    }
//}


/// returns a random elements from the array
func any<T>(items:[T]) -> T {
    return items[Int(arc4random_uniform(UInt32(items.count)))]
}

/// true is using an iPad
let usingIpad = (UIDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)

/// true if using widescreen iPhone
let usingIphoneWidescreen = (UIScreen.mainScreen().bounds.landscapeWidth() == 568.0)
let usingIphone6 = (UIScreen.mainScreen().bounds.landscapeWidth() == 667.0)
let usingIphone6plus = (UIScreen.mainScreen().bounds.landscapeWidth() == 736.0)

extension CGRect {
    func landscapeWidth() -> CGFloat {
        return max(self.width, self.height)
    }
}

/// allows to get device specific values
func factor<T>(forPhone forPhone:T, forPad:T) -> T {
    if usingIpad { return forPad }
    else { return forPhone }
}


/// allows to get device specific values
func factor2<T>(forPhone forPhone:T, forPhone3x:T, forPad:T) -> T {
    if usingIpad { return forPad }
    else if usingIphone6plus { return forPhone3x }
    else { return forPhone }
}



func clamp<T:Comparable>(min: T, max: T, value: T) -> T {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

let M_PI_8:CGFloat  = CGFloat(M_PI_4)/2.0
let M_PI_16:CGFloat = CGFloat(M_PI_4)/4.0
let M_PI_24:CGFloat = CGFloat(M_PI_4)/6.0
let M_PI_32:CGFloat = CGFloat(M_PI_4)/8.0

func degToRad(degrees:CGFloat) -> CGFloat {
    return CGFloat(M_PI) * degrees / CGFloat(180.0)
}

func radToDeg(radians:CGFloat) -> CGFloat {
    return radians * CGFloat(180.0) / CGFloat(M_PI)
}


func unitRandom() -> CGFloat {
    return CGFloat(drand48())
    //return CGFloat(arc4random()) / (0x100000000 as CGFloat)
}

func measure(name:String, block:()->()) {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let end = CFAbsoluteTimeGetCurrent()
    debug_print("MEASURE: \(name) took \(end-start)")
}


extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

