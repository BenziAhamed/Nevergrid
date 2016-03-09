//
//  LevelParser.swift
//  OnGettingThere
//
//  Created by Benzi on 20/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation


class LevelParser : NSObject, NSXMLParserDelegate {
    
    var xmlParser:NSXMLParser!
    var level:Level!
    var tileHeight = 0
    var tileWidth = 0
    
    var currentObjectGroup = LevelObjectGroup.None
    var currentLevelObject = LevelObject()
    var tokens = Stack<Token>()
    
    var gridIndex = 0
    var wallIndex = 0
    var blockRoundedIndex = 0
    var cellRoundedIndex = 0
    var zonemapIndex = 0

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if(elementName=="map") {
            tokens.push(Token.Map)
            level.rows =  (attributeDict["height"]! as NSString).integerValue
            level.columns = (attributeDict["width"]! as NSString).integerValue
            tileHeight = (attributeDict["tileheight"]! as NSString).integerValue
            tileWidth = (attributeDict["tilewidth"]! as NSString).integerValue
            level.initializeCells()
        }
            
        else if elementName == "layer" {
            let layerName = attributeDict["name"]! as NSString
            switch(layerName){
            case "grid": tokens.push(Token.GridLayer)
            case "walls": tokens.push(Token.WallLayer)
            case "blockrounded": tokens.push(Token.RoundedBlockLayer)
            case "cellrounded": tokens.push(Token.RoundedCellLayer)
            case "zonemap": tokens.push(Token.zoneMap)
            default:break
            }
        }
            
        else if(elementName=="tile") {
            let currentLayer = tokens.top()
            var gid = UInt((attributeDict["gid"]! as NSString).integerValue)

            switch(currentLayer) {
                
            case Token.WallLayer:
                if gid > 0 {
                    gid -= 1
                }
                level.cellAt(wallIndex++).walls += gid
                
            case Token.GridLayer:
                if gid > 0 {
                    gid -= 1
                }
                level.cellAt(gridIndex++).walls += gid
                
            case Token.RoundedCellLayer:
                level.cellAt(cellRoundedIndex++).cellRoundedness = gid
                
            case Token.RoundedBlockLayer:
                level.cellAt(blockRoundedIndex++).blockRoundedness = gid
                
                
            case Token.zoneMap:
                var zone:UInt = 0
                switch gid {
                case 34: zone = 1
                case 37: zone = 2
                case 38: zone = 3
                case 41: zone = 4
                case 42: zone = 5
                case 43: zone = 6
                case 44: zone = 7
                default: break
                }
//                if zone > 0 {
//                    let (c,r) = level.getColumnRow(zonemapIndex)
//                    println("\(c),\(r) = gid:\(gid) --> zone:\(zone)")
//                }
                level.cellAt(zonemapIndex++).zone = zone
                
            default:
                break
            }
            return
        }
            
        else if(elementName=="property") {
            
            // a property can belong to any element
            // we try to identify by looking at the current token stack
            // to process which is which
            if tokens.top() == Token.Map {
                
                // set the top level properties of the map
                
                let name = attributeDict["name"]! as String
                let value = attributeDict["value"]! as NSString
                
                switch name {
                    case "title": level.title = value as String
                    case "mode":
                        switch value {
                            case "merged": level.zoneBehaviour = ZoneBehaviour.Mergeable
                            case "standalone": level.zoneBehaviour = ZoneBehaviour.Standalone
                            default:break
                        }
                    case "zone":
                        self.level.initialZone = UInt(value.integerValue)
                    
                    default:
                        level.conditions[name] = value as String
                }
                
            }
            else if tokens.top() == Token.Object {
                // this property belongs to a level object
                // copy in the name value pair to the dict
                currentLevelObject.properties[ (attributeDict["name"]! as String) ] = (attributeDict["value"]! as String)
            }

        }
            
        else if elementName == "objectgroup" {
            
            var name = attributeDict["name"]! as NSString
            switch(name) {
            case "players" : currentObjectGroup = LevelObjectGroup.Player
            case "cells" : currentObjectGroup = LevelObjectGroup.Cell
            case "goals" : currentObjectGroup = LevelObjectGroup.Item // TODO: remove this, kept for backward compatibility
            case "items" : currentObjectGroup = LevelObjectGroup.Item
            case "enemies" : currentObjectGroup = LevelObjectGroup.Enemy
            case "powerups" : currentObjectGroup = LevelObjectGroup.Powerup
            case "portals" : currentObjectGroup = LevelObjectGroup.Portal
            default: break
            }
        }
            
            
        else if(elementName=="object") {
            
            tokens.push(Token.Object)
            
            currentLevelObject = LevelObject()
            
            var x = (attributeDict["x"]! as NSString).integerValue
            var y = (attributeDict["y"]! as NSString).integerValue
            var type = attributeDict["type"]! as NSString
            
            let r = y / tileHeight
            let c = x / tileWidth
            
            currentLevelObject.group = currentObjectGroup
            currentLevelObject.type = type as String
            currentLevelObject.location = LocationComponent(row: r, column: c)
            
        }
    }
    

    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "object" {
            level.levelObjects.append(currentLevelObject)
            tokens.pop()
        } else if elementName == "layer" {
            tokens.pop()
        } else if elementName == "map" {
            tokens.pop()
        }
    }
    
    
    func parse() {
        xmlParser.parse()
    }
    
    init(levelItem:LevelItem) {
        xmlParser = NSXMLParser(contentsOfURL: levelItem.url)
        level = Level()
        level.info = levelItem
        super.init()
        xmlParser.delegate = self
    }
    
    class func parse(levelItem:LevelItem) -> Level {
        let parser = LevelParser(levelItem: levelItem)
        parser.parse()
        return parser.level
    }
    
    enum Token {
        case Map
        case Object
        case GridLayer
        case WallLayer
        case RoundedCellLayer
        case RoundedBlockLayer
        case zoneMap
    }
}



