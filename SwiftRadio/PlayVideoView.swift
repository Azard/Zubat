//
//  PlayVideoView.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/17.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayVideoView: UIView {

    var player : AVPlayer?{
        get{
            let tmp = self.layer as! AVPlayerLayer
            return tmp.player
        }
        set(newPlayer){
            let tmp = self.layer as! AVPlayerLayer
            tmp.player = newPlayer
        }
    }
    var playerLayer : AVPlayerLayer?{
        get{
            let tmp = self.layer as! AVPlayerLayer
            return tmp
        }
    }
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
