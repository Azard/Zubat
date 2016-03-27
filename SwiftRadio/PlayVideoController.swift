//
//  PlayVideoController.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/17.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Foundation

class PlayVideoController: UIViewController {

    var videoName = ""
    var avPlayerViewController:AVPlayerViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        playVideo()
    }
    func playVideo(){
        let url:NSURL = NSURL(fileURLWithPath: Video.videoDirPath + videoName)
        print(videoName)
        let player = AVPlayer(URL: url)
        self.avPlayerViewController = AVPlayerViewController()
        self.avPlayerViewController.player = player
        //self.avPlayerViewController.
        
        self.presentViewController(self.avPlayerViewController, animated: true){
            () -> Void in
            player.pause()
            //self.avPlayerViewController.player?.play()
        }
        
        
    }
    func stopVideo(){
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
