//
//  TextNode.swift
//  NeverGrid
//
//  Created by Benzi on 09/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class TextNode : SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    var text:String = ""
    var fontName:String = FactoredSizes.numberFont
    var fontSize:CGFloat = 52.0
    var fontColor:UIColor = UIColor.whiteColor()
    var shadowColor:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    var shadowOffset:CGSize = CGSizeMake(0.0, 2.0)
    var shadowBlur:CGFloat = 5.0
    var enableShadow:Bool = true
    
    let deviceScale = UIScreen.mainScreen().scale
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    
    init() {
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeZero)
        textStyle.alignment = NSTextAlignment.Center;
    }
    
    
    func render() {
        // get the size of the text
        let nsText = text as NSString
        let textFont = UIFont(name: fontName, size: fontSize)!
//        let textFontAttributes:[NSString:AnyObject] = [
//            NSFontAttributeName: textFont,
//            NSForegroundColorAttributeName: fontColor,
//            NSParagraphStyleAttributeName: textStyle
//        ]
        
        var textFontAttributes = [String:AnyObject]()
        textFontAttributes[NSFontAttributeName] = textFont
        textFontAttributes[NSForegroundColorAttributeName] = fontColor
        textFontAttributes[NSParagraphStyleAttributeName] = textStyle
        
        let size = nsText.sizeWithAttributes(textFontAttributes)
        let sizeWithShadow = size.expand(dw: 2.0*(shadowBlur+shadowOffset.width), dh: 2.0*(shadowBlur+shadowOffset.height)).expand(dw: 0.0, dh: 0.2*size.height)
        let imageSize = sizeWithShadow.scale(deviceScale)
        
        
        // create a CG context and render text in there
        UIGraphicsBeginImageContext(imageSize)
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context, deviceScale, deviceScale)
        
        CGContextSaveGState(context)
        if enableShadow {
            let shadow: NSShadow = NSShadow(color: shadowColor, offset: shadowOffset, blurRadius: shadowBlur)
            CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor!.CGColor)
        }
        
        let textRect = CGRectMake(
            (sizeWithShadow.width-size.width)/2.0,
            (sizeWithShadow.height-textFont.xHeight)/2.0,
            size.width,
            size.height
        )
        nsText.drawInRect(textRect, withAttributes: textFontAttributes)
        CGContextRestoreGState(context)
        
        
//        // debug
//        let imageRect = CGRectMake(0, 0, sizeWithShadow.width, sizeWithShadow.height)
//        
//        UIColor.yellowColor().setStroke()
//        CGContextStrokeRect(context, imageRect)
//
//        UIColor.blueColor().setStroke()
//        CGContextStrokeRect(context, textRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let tex = SKTexture(CGImage: image.CGImage!)
        
        UIGraphicsEndImageContext()
        
        // update our texture
        self.size = sizeWithShadow
        self.texture = tex
    }
}



extension NSShadow {
    convenience init(color: AnyObject!, offset: CGSize, blurRadius: CGFloat) {
        self.init()
        self.shadowColor = color
        self.shadowOffset = offset
        self.shadowBlurRadius = blurRadius
    }
}