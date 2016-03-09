//
//  UIKit.Extensions.swift
//  MrGreen
//
//  Created by Benzi on 08/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    func scale(by:CGFloat) -> CGSize {
        return CGSizeMake(self.width*by, self.height*by)
    }
    
    func expand(dw dw:CGFloat, dh:CGFloat) -> CGSize {
        return CGSizeMake(self.width+dw, self.height+dh)
    }
    
    func asPoint() -> CGPoint {
        return CGPointMake(self.width, self.height)
    }
    
    func aspectFitTo(target:CGSize) -> CGSize {
        let ratioW = target.width / self.width
        let ratioH = target.height / self.height
        let ratio = min(ratioW, ratioH)
        return CGSizeMake(self.width*ratio, self.height*ratio)
    }
    
    func aspectFillTo(target:CGSize) -> CGSize {
        let ratioW = target.width / self.width
        let ratioH = target.height / self.height
        let ratio = max(ratioW, ratioH)
        return CGSizeMake(self.width*ratio, self.height*ratio)
    }
}

extension CGRect {
    /// scales a rectangle around the spceified pivot
    func scale(amount:CGFloat, pivot:CGPoint) -> CGRect {
        let position = self.origin.subtract(pivot).multiply(amount)
        return CGRectMake(position.x, position.y, self.width * amount, self.height * amount)
    }
    
    /// scales a rectangle around the origin 0,0
    func scale(amount:CGFloat) -> CGRect {
        return scale(amount, pivot:CGPointZero)
    }
    
    /// returns the mid point of the rectangle
    func mid() -> CGPoint {
        return CGPointMake(self.midX, self.midY)
    }
    
    
    func resize(dw dw:CGFloat, dh:CGFloat) -> CGRect {
        return CGRectMake(self.origin.x, self.origin.y, self.width+dw, self.height+dh)
    }
    
    
    /// computes the coverage of this rect for an outer rect
    func coverage(forRect forRect:CGRect) -> CGFloat {
        let widthCoverage = self.width / forRect.width
        let heightCoverage = self.height / forRect.height
//        println("widthCoverage:\(widthCoverage) = \(self.width)/\(forRect.width)")
//        println("heightCoverage:\(heightCoverage) = = \(self.height)/\(forRect.height)")
        let coverage = max(widthCoverage, heightCoverage)
        return coverage
    }
}

extension UIColor {
    convenience init(red:CGFloat, green:CGFloat, blue:CGFloat) {
        self.init(red:red/255.0, green:green/255.0, blue:blue/255.0, alpha:1.0)
    }
    
    convenience init(rgb:[CGFloat]) {
        self.init(red:rgb[0]/255.0, green:rgb[1]/255.0, blue:rgb[2]/255.0, alpha:1.0)
    }
    
    convenience init(rgba:[CGFloat]) {
        self.init(red:rgba[0]/255.0, green:rgba[1]/255.0, blue:rgba[2]/255.0, alpha:rgba[3]/255.0)
    }
    
    class func greenSea() -> UIColor {
        return UIColor(red: 42, green: 160, blue: 131)
    }
    
    class func belizeHole() -> UIColor {
        return UIColor(red: 49, green: 127, blue: 190)
    }
    
    class func amethyst() -> UIColor {
        return UIColor(red: 165, green: 99, blue: 190)
    }
    
    class func midnightBlue() -> UIColor {
        return UIColor(red: 44, green: 61, blue: 82)
    }
    
    class func asbestos() -> UIColor {
        return UIColor(red: 128, green: 140, blue: 141)
    }
    
    class func pomegranate() -> UIColor {
        return UIColor(red: 188, green: 59, blue: 36)
    }
    
    class func carrot() -> UIColor {
        return UIColor(red: 226, green: 128, blue: 44)
    }
    
    class func sunflower() -> UIColor {
        return UIColor(red: 243, green: 207, blue: 63)
    }
    
    class func peterRiver() -> UIColor {
        return UIColor(red: 52, green: 152, blue: 219)
    }
    
}


// via PaintCode
extension UIColor {
    func colorWithHue(newHue: CGFloat) -> UIColor  {
        var saturation:CGFloat = 1.0, brightness:CGFloat = 1.0, alpha:CGFloat = 1.0
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    func colorWithSaturation(newSaturation: CGFloat) -> UIColor  {
        var hue:CGFloat = 1.0, brightness:CGFloat = 1.0, alpha:CGFloat = 1.0
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    func colorWithBrightness(newBrightness: CGFloat) -> UIColor  {
        var hue:CGFloat = 1.0, saturation:CGFloat = 1.0, alpha:CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    func colorWithAlpha(newAlpha: CGFloat) -> UIColor  {
        var hue:CGFloat = 1.0, saturation:CGFloat = 1.0, brightness:CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    func colorWithHighlight(highlight: CGFloat) -> UIColor  {
        var red:CGFloat = 1.0, green:CGFloat = 1.0, blue:CGFloat = 1.0, alpha:CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
    }
    func colorWithShadow(shadow: CGFloat) -> UIColor  {
        var red:CGFloat = 1.0, green:CGFloat = 1.0, blue:CGFloat = 1.0, alpha:CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
    }
    func negative() -> UIColor {
        var red:CGFloat = 1.0, green:CGFloat = 1.0, blue:CGFloat = 1.0, alpha:CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: 1-red, green: 1-green, blue: 1-blue, alpha: alpha)
    }
    func invert() -> UIColor {
        var hue:CGFloat = 1.0, saturation:CGFloat = 1.0, brightness:CGFloat = 1.0, alpha:CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: 1-hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}




// http://higherorderfun.com/blog/2012/06/03/math-for-game-programmers-05-vector-cheat-sheet/
extension CGPoint {
    
    /// returns a vector form of the point
    func vector() -> CGVector {
        return CGVectorMake(self.x, self.y)
    }
    
    
    func clampX(range:(CGFloat,CGFloat)) -> CGPoint {
        let (min,max) = range
        let x = clamp(min, max: max, value: self.x)
        return CGPointMake(x,self.y)
    }
    
    func clampY(range:(CGFloat,CGFloat)) -> CGPoint {
        let (min,max) = range
        let y = clamp(min, max: max, value: self.y)
        return CGPointMake(self.x,y)
    }
    
    
    
    /// create a unit vector facing the specified angle
    /// angle 0 means pointing right
    static func toAngle(angle:CGFloat) -> CGPoint {
        return CGPointMake(cos(angle), sin(angle))
    }
    
    /// Returns the component-wise addition of the vectors.
    func add(p:CGPoint) -> CGPoint {
        return CGPointMake(self.x+p.x, self.y+p.y)
    }
    
    /// Returns the vector with the scalar added
    func add(s:CGFloat) -> CGPoint {
        return CGPointMake(self.x+s, self.y+s)
    }
    
    
    /// Returns the vector with the dx,dy factors added
    func offset(dx dx:CGFloat, dy:CGFloat) -> CGPoint {
        return CGPointMake(self.x+dx, self.y+dy)
    }
    
    /// Returns the component-wise subtraction of the vectors.
    func subtract(p:CGPoint) -> CGPoint {
        return CGPointMake(self.x-p.x, self.y-p.y)
    }
    
    /// Returns the vector with the scalar subtracted
    func subtract(s:CGFloat) -> CGPoint {
        return CGPointMake(self.x-s, self.y-s)
    }
    
    
    /// Returns the component-wise multiplication of the vectors.
    func multiply(p:CGPoint) -> CGPoint {
        return CGPointMake(self.x*p.x, self.y*p.y)
    }
    
    /// Returns the component-wise division of the vectors.
    func divide(p:CGPoint) -> CGPoint {
        return CGPointMake(self.x/p.x, self.y/p.y)
    }
    
    /// Returns the vector with all components multiplied by the scalar parameter.
    func multiply(s:CGFloat) -> CGPoint {
        return CGPointMake(self.x*s, self.y*s)
    }
    
    /// Returns the vector with all components divided by the scalar parameter.
    func divide(s:CGFloat) -> CGPoint {
        return CGPointMake(self.x/s, self.y/s)
    }
    
    
    /// Returns the dot product between the two vectors.
    func dot(p:CGPoint) -> CGFloat {
        return self.x*p.x + self.y*p.y
    }
    
    
    /// Returns the z component of the cross product of the two vectors augmented to 3D.
    func cross(p:CGPoint) -> CGFloat {
        return self.x*p.y - self.y*p.x
    }
    
    
    /// Returns the length of the vector.
    func length() -> CGFloat {
        return sqrt(self.x*self.x + self.y*self.y)
    }
    
    
    /// Returns the square of the length of the vector. Useful when you just want to compare two vectors to see which is longest, as this avoids computing square roots
    func lengthSquared() -> CGFloat {
        return self.x*self.x + self.y*self.y
    }
    
    /// Returns a vector pointing on the same direction, but with a length of 1.
    func unit() -> CGPoint {
        return self.divide(self.length())
    }
    
    /// Returns the vector rotated 90 degrees left. Useful for computing normals. (Assumes that y axis points up, otherwise this is turnRight)
    func turnLeft() -> CGPoint {
        return CGPointMake(-self.y, self.x)
    }
    
    
    /// Returns the vector rotated 90 degrees right. Useful for computing normals. (Assumes that y axis points up, otherwise this is turnLeft)
    func turnRight() -> CGPoint {
        return CGPointMake(self.y, -self.x)
    }
    
    
    /// Rotates the vector by the specified angle.
    /// This is an extremely useful operation, though it is rarely found in Vector classes.
    /// Equivalent to multiplying by the 2×2 rotation matrix.
    func rotate(angle:CGFloat) -> CGPoint {
        return CGPointMake(self.x*cos(angle)-self.y*sin(angle), self.x*sin(angle)+self.y*cos(angle))
    }
    
    /// Rotates the vector by the specified angle about the specified pivot.
    /// This is an extremely useful operation, though it is rarely found in Vector classes.
    /// Equivalent to multiplying by the 2×2 rotation matrix.
    func rotateAround(pivot:CGPoint, angle:CGFloat) -> CGPoint {
        return self.subtract(pivot).rotate(angle).add(pivot)
    }
    
    /// Returns the angle that the vector points to.
    func angle() -> CGFloat {
        return atan2(self.y, self.x)
    }
    
    /// Limits the vector conmponents by the amount
    func limit(amount:CGFloat) -> CGPoint {
        let magnitude = self.length()
        if magnitude > amount {
            let ratio = CGFloat(sqrt(amount)) / magnitude
            return self.multiply(ratio)
        }
        return self
    }
    
    
    // -------------------------------------------------------
    // MARK: Useful functions
    // -------------------------------------------------------
    
    /// Distance between two points
    func distanceTo(b:CGPoint)->CGFloat {
        return self.subtract(b).length()
    }
    
    /// Angle between specified point and self
    /// in relation to origin
    func angleTo(b:CGPoint)->CGFloat {
        return self.subtract(b).angle()
    }
    
    /// Alignment
    func align(size:CGPoint, alignment:CGPoint) -> CGPoint {
        return self.add(size.multiply(alignment))
    }
    
    /// Point at distance
    func pointTowards(point:CGPoint, distance:CGFloat) -> CGPoint {
        let dir = self.subtract(point).unit()
        return self.add(dir.multiply(distance))
    }
    
    /// Interpolate to a point by amount
    func lerp(p:CGPoint, byAmount t:CGFloat) -> CGPoint {
        return self.multiply((1-t)).add(p.multiply(t))
    }
    
    /// Gets the mid point between this point and the specified
    /// point using interpolation
    func midTo(p:CGPoint) -> CGPoint {
        return self.lerp(p, byAmount: 0.5)
    }
    
    /// Finding the normal of a line segment
    func normalTo(p:CGPoint) -> CGPoint {
        return self.subtract(p).unit().turnLeft()
    }
    
    
    /// Determining if the angle between two vectors is less than alpha
    func atAngleLessThan(p:CGPoint, alpha:CGFloat) -> Bool {
        return self.unit().dot(p.unit()) < cos(alpha)
    }
}
