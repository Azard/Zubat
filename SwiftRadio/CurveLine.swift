//
//  curveLine.swift
//  test
//
//  Created by guoyanchang on 16/5/8.
//  Copyright © 2016年 guoyanchang. All rights reserved.
//

import UIKit

class CurveLine: UIView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    var startingPoint : CGPoint = CGPoint()
    var endingPoint : CGPoint = CGPoint()
    var points : [CGPoint] = []
    var line : UIBezierPath = UIBezierPath()
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
    //MARK: drawRect
    func passingValues(Points : [CGPoint],minX:CGFloat,minY:CGFloat)
    {
        for point in Points{
            self.points.append(CGPoint(x: point.x-minX,y: point.y-minY))
        }
    }
    override func drawRect(rect: CGRect)
    {
        //print(points[0])
        
        line.moveToPoint(points[0])
        //line.addLineToPoint(points[points.count-1])
        for point in points{
            line.addLineToPoint(point)
        }
        //line.lineWidth = 1
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
        line.stroke()
        
    }
    
}
