//
//  Rectangle.swift
//  test
//
//  Created by guoyanchang on 16/4/18.
//  Copyright © 2016年 guoyanchang. All rights reserved.
//

import UIKit

class Rectangle: UIView {
    var color : Int = 1
    override init(frame: CGRect) {
        super.init(frame: frame)
        //把背景色设为透明
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let pathRect = CGRectInset(self.bounds, 1, 1)
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 20)
        path.lineWidth = 3
        UIColor.clearColor().setFill()
        if(color == 1){
            UIColor.redColor().setStroke()
        }
        else if(color == 2){
            UIColor.blackColor().setStroke()
        }
        else if(color == 3){
            UIColor.yellowColor().setStroke()
        }
        else if(color == 4){
            UIColor.blueColor().setStroke()
        }
        path.fill()
        path.stroke()
    }
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
