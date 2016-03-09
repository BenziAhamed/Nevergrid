//
//  GridSystem.swift
//  gettingthere
//
//  Created by Benzi on 23/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GridSystemOptions {
    
    var frame:CGRect = CGRectMake(0, 0, 0, 0)
    
    var clearanceFromTopInPoints:CGFloat = 0.0
    var clearanceFromBottomInPoints:CGFloat = 0.0
    var clearanceFromLeftInPoints:CGFloat = 0.0
    var clearanceFromRightInPoints:CGFloat = 0.0
    
    
    var preferredCellSizeInPoints:CGFloat = 0.0
    var cellSpacingInPoints:CGFloat = 0.0
    var cellExtendsInPoints:CGFloat = 0.0
    
    var forcePreferredCellSize:Bool = false
    
    var rows:Int = 0
    var columns:Int = 0
    
    var clearance:CGFloat {
    set {
        clearanceFromBottomInPoints = newValue
        clearanceFromTopInPoints = newValue
        clearanceFromLeftInPoints = newValue
        clearanceFromRightInPoints = newValue
    }
    get { return 0.0 }
    }

    var clearanceTopBottom:CGFloat {
    set {
        clearanceFromBottomInPoints = newValue
        clearanceFromTopInPoints = newValue
    }
    get { return 0.0 }
    }
    
    var clearanceLeftRight:CGFloat {
    set {
        clearanceFromLeftInPoints = newValue
        clearanceFromRightInPoints = newValue
    }
    get { return 0.0 }
    }
}


// Making on-screen grid mapping calculations easy for everyone!
class GridSystem {

    var x:CGFloat = 0.0
    var y:CGFloat = 0.0
    var rows:Int = 0
    var columns:Int = 0
    var sideLength:CGFloat = 0.0
    var cellExtends:CGFloat = 0.0
    
    var cellSpacing:CGFloat = 0.0
    var frame:CGRect!
    var gridFrame:CGRect!
    var cellNodeSize:CGSize!
   
    var childNodePositionForCell:CGPoint!
    
    
    init(options:GridSystemOptions)
    {
        // this is our overall frame, comprising both the grid and surrounding empty space
        self.frame = options.frame
        self.cellSpacing = options.cellSpacingInPoints
        self.cellExtends = options.cellExtendsInPoints
        
        self.rows = options.rows
        self.columns = options.columns

        
        if options.forcePreferredCellSize {
            initWithForcedSize(options)
        } else {
            initWithCenteredGrid(options)
        }
        
        
        self.cellNodeSize = CGSizeMake(self.sideLength, self.sideLength)


        self.childNodePositionForCell = CGPointMake(
            sideLength/2.0,
            sideLength/2.0+cellExtends
        )

    }
    
    func initWithForcedSize(options:GridSystemOptions) {
        self.sideLength = options.preferredCellSizeInPoints
        self.x = options.frame.origin.x
        self.y = options.frame.origin.y
        let gridWidth = self.sideLength * CGFloat(columns) + self.cellSpacing * CGFloat(columns-1)
        let gridHeight = self.sideLength * CGFloat(rows) + self.cellSpacing * CGFloat(rows-1)
        self.gridFrame = CGRectMake(x, y-cellExtends, gridWidth, gridHeight+cellExtends)
    }
    
    func initWithCenteredGrid(options:GridSystemOptions) {
        let availableWidth = frame.width - (options.clearanceFromLeftInPoints+options.clearanceFromRightInPoints) - CGFloat(columns-1)*cellSpacing
        let availableHeight = frame.height - (options.clearanceFromTopInPoints+options.clearanceFromBottomInPoints) - CGFloat(rows-1)*cellSpacing
        
        // if a preferred size is mentioned, check if that will
        // allows us to fit the grid inside the available frame
        // if so, we are done. If that doesnt work out, try dividing
        // the height with the row count to get an estimate of the sidelength
        // and see if that will fit the columns for the available width.g
        // If that also fails, final option is to get sidelength by splitting
        // up the columns based on the width
        if (options.preferredCellSizeInPoints != 0.0) {
            self.sideLength = options.preferredCellSizeInPoints
            if self.sideLength * CGFloat(rows) > availableHeight {
                self.sideLength = availableHeight / CGFloat(rows)
            }
        } else {
            self.sideLength = availableHeight / CGFloat(rows)
        }
        if (CGFloat(columns) * self.sideLength > availableWidth) {
            self.sideLength = availableWidth / CGFloat(columns)
        }
        
        // find the origin of the grid
        let gridWidth = self.sideLength * CGFloat(columns) + self.cellSpacing * CGFloat(columns-1)
        let gridHeight = self.sideLength * CGFloat(rows) + self.cellSpacing * CGFloat(rows-1)
        
        let bufferWidth = availableWidth - gridWidth
        let bufferHeight = availableHeight - gridHeight
        
        self.x = frame.origin.x + options.clearanceFromLeftInPoints + bufferWidth/2
        self.y = frame.origin.y + options.clearanceFromBottomInPoints + bufferHeight/2
        
        self.gridFrame = CGRectMake(x, y-cellExtends, gridWidth, gridHeight+cellExtends)
    }
    


    
    /// gets the entity position with respect to the world node
    /// coordinate system
    func getEntityPosition(location:LocationComponent) -> CGPoint {
        return self.getEntityPosition(row: location.row, column: location.column)
    }
    
    /// gets the enemy position with respect to the world node
    /// coordinate system, monsters are offset to the top right slightly
    /// in order to accomodate their larger size
    func getEnemyPosition(location:LocationComponent, type:EnemyType) -> CGPoint {
        if type == EnemyType.Monster {
            // monsters are twice as large
            return self.getEntityPosition(row: location.row, column: location.column).add(self.sideLength/2.0)
        } else {
            return self.getEntityPosition(row: location.row, column: location.column)
        }
    }
    
    /// gets the entity position with respect to the world node
    /// coordinate system
    func getEntityPosition(row row:Int, column:Int) -> CGPoint {
        let c = getCellPosition(row: row, column: column)
        return CGPointMake(
            c.x + sideLength/2,
            c.y + sideLength/2
        )
    }
    
    /// gets the cell position with respect to the world node
    /// coordinate system
    func getCellPosition(row row:Int, column:Int) -> CGPoint {
        let (px,py) = (
            x + sideLength * CGFloat(column) + cellSpacing * CGFloat(column-1),
            y + sideLength * CGFloat(rows-row-1) + cellSpacing * CGFloat(rows-row-1)
        )
        return CGPointMake(px,py)
    }
    
    
    /// gets a size comopnent based on the current sidelength
    /// property
    func getSize(factor:CGFloat) -> CGSize {
        let s = sideLength * factor
        return CGSizeMake(s,s)
    }
    
//    func getThickness(factor:CGFloat) -> CGFloat {
//        return sideLength * factor
//    }
}

