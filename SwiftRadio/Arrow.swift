//
//  Arrow.swift
//  test
//
//  Created by guoyanchang on 16/4/18.
//  Copyright © 2016年 guoyanchang. All rights reserved.
//

import UIKit

class Arrow: UIView {
    
    var startingPoint : CGPoint = CGPoint()
    var endingPoint : CGPoint = CGPoint()
    var arrowLength : CGFloat = CGFloat()
    var arrowPath : UIBezierPath = UIBezierPath()
    var color : Int = 1
    
    
    
    //MARK: initFrame
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func passingValues(startingPointValue : CGPoint, endingPointValue : CGPoint)
    {
        self.startingPoint = startingPointValue
        self.endingPoint = endingPointValue
        
        let xDistance : CGFloat = self.endingPoint.x - self.startingPoint.x
        let yDistance : CGFloat = self.endingPoint.y - self.startingPoint.y
        
        self.arrowLength = sqrt((xDistance * xDistance) + (yDistance * yDistance))
    }
    
    //MARK: drawRect
    
    override func drawRect(rect: CGRect)
    {
        //passingValues(CGPoint(x: 0,y: 0), endingPointValue: CGPoint(x: rect.width,y: rect.height))
        let tailWidth : CGFloat = max(2.0, self.arrowLength * 0.03)
        let headLength : CGFloat = max(self.arrowLength * 0.1, 5.0)
        let headWidth : CGFloat = headLength * 0.9
        
        self.layer.shadowRadius = max(4.0, tailWidth)
        
        self.arrowPath = self.bezierPathWithArrowFromPoint(self.startingPoint, endPoint: self.endingPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        if(color == 1){
            UIColor.redColor().setFill()
            UIColor.redColor().setStroke()
        }
        else if(color == 2){
            UIColor.blackColor().setFill()
            UIColor.blackColor().setStroke()
        }
        else if(color == 3){
            UIColor.yellowColor().setFill()
            UIColor.yellowColor().setStroke()
        }
        else if(color == 4){
            UIColor.blueColor().setFill()
            UIColor.blueColor().setStroke()
        }
        
        self.arrowPath.fill()
        self.arrowPath.stroke()
        
        self.layer.shadowPath  = self.arrowPath.CGPath
        
    }
    
    
    //MARK: Creating Path
    
    func bezierPathWithArrowFromPoint(startingPoint : CGPoint, endPoint : CGPoint, tailWidth : CGFloat, headWidth : CGFloat, headLength : CGFloat) -> UIBezierPath
    {
        
        let length = hypotf( Float(endPoint.x) - Float(startingPoint.x) , Float(endPoint.y) - Float(startingPoint.y))
        
        let tailLength : CGFloat = CGFloat(length) - headLength
        
        let points = [CGPointMake(0, tailWidth / 2), CGPointMake(tailLength, tailWidth / 2), CGPointMake(tailLength, headWidth / 2), CGPointMake(CGFloat(length), 0), CGPointMake(tailLength, (-headWidth) / 2), CGPointMake(tailLength, (-tailWidth) / 2 ), CGPointMake(0, (-tailWidth) / 2)]
        
        let cosine : CGFloat = (endPoint.x - startingPoint.x) / CGFloat(length)
        let sine : CGFloat = (endPoint.y - startingPoint.y) / CGFloat(length)
        var transform : CGAffineTransform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startingPoint.x, ty: startingPoint.y)
        let cgPath : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddLines(cgPath, &transform, points, points.count)
        CGPathCloseSubpath(cgPath)
        
        let bezierPath : UIBezierPath = UIBezierPath(CGPath: cgPath)
        bezierPath.lineCapStyle = CGLineCap.Round
        bezierPath.lineJoinStyle = CGLineJoin.Round
        
        return bezierPath
    }
    
    
    
}
