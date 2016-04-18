//
//  Rectangle.swift
//  test
//
//  Created by guoyanchang on 16/4/18.
//  Copyright © 2016年 guoyanchang. All rights reserved.
//

import UIKit

class Rectangle: UIView {
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
        UIColor.redColor().setStroke()
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
