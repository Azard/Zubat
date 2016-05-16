//
//  line.swift
//  test
//
//  Created by guoyanchang on 16/5/7.
//  Copyright © 2016年 guoyanchang. All rights reserved.
//

import UIKit

class SLine: UIView {
    var startingPoint : CGPoint = CGPoint()
    var endingPoint : CGPoint = CGPoint()
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
    func passingValues(startingPointValue : CGPoint, endingPointValue : CGPoint)
    {
        self.startingPoint = startingPointValue
        self.endingPoint = endingPointValue
    }
    override func drawRect(rect: CGRect)
    {
        //passingValues(CGPoint(x: 0,y: 0), endingPointValue: CGPoint(x: rect.width,y: rect.height))
        print("sline")
        line.moveToPoint(startingPoint)
        line.addLineToPoint(endingPoint)
        line.lineWidth = 3
        //line.closePath()
        //UIColor.redColor().setFill()
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
        //line.fill()
        line.stroke()
        
    }
    
    
    //MARK: Creating Path
    
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
