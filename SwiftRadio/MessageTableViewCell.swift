//
//  MessageTableViewCell.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/25.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 78/255, green: 82/255, blue: 93/255, alpha: 0.6)
        selectedBackgroundView  = selectedView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }




    @IBOutlet weak var messageTime: UILabel!

    @IBOutlet weak var messageType: UILabel!
    
    func configureMessageCell(scene: Scene) {
        if(scene.type == 0){
            messageType.text = scene.sceneName + "-os"
        }
        else if(scene.type == 1){
            messageType.text = scene.sceneName + "-dub"
        }
        var tmp = scene.startTime/100
        var h = tmp/3600
        var m = (tmp%3600)/60
        var s = tmp%60
        let startStamp = "\(h):\(m):\(s).\(scene.startTime%100)"
        tmp = scene.startTime/100
        h = tmp/3600
        m = (tmp%3600)/60
        s = tmp%60
        let endStamp = "\(h):\(m):\(s).\(scene.endTime%100)"
        messageTime.text = startStamp + "-" + endStamp
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageType.text  = nil
        messageType.text  = nil
    }
}
