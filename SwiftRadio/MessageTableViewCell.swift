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
    
    func configureMessageCell(message: Message) {
        if(message.type == 1){
            messageType.text = "声音"
        }
        else{
            messageType.text = "文字"
        }
        
        messageTime.text = message.timeStamp
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageType.text  = nil
        messageType.text  = nil
    }
}
