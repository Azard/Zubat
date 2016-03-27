//
//  ViewController.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/17.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import UIKit
import AVFoundation

class EditVideoController: UIViewController {

    var curVideo : String = ""
    var playing : Bool = false
    var recorder:AVAudioRecorder? //录音器
    var player:AVAudioPlayer? //播放器
    var recorderSeetingsDic:[String : AnyObject]? //录音器设置参数数组
    var curSeconds:Int = 0
    var allMessages : [Int:Message]?
    
    
    @IBOutlet weak var textButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBAction func textMessage(sender: UIButton) {
        textAppear()
        
    }
    var recording : Bool = false
    var tmpSecond = 0
    @IBAction func startRecord(sender: UIButton) {
        
        
        if recording == false{
            tmpSecond = curSeconds
            let soundPath = curVideo+"\(tmpSecond).acc"
            recording = true
            print(Message.soundDirPath + soundPath)
            //初始化录音器
            let session:AVAudioSession = AVAudioSession.sharedInstance()
            //设置录音类型
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            //设置支持后台
            try! session.setActive(true)

            recorder = try! AVAudioRecorder(URL: NSURL(string: Message.soundDirPath + soundPath)!,settings: recorderSeetingsDic!)
            if recorder != nil {
                recorder!.meteringEnabled = true
                recorder!.prepareToRecord()
                recorder!.record()
                sender.setTitle("完成", forState: UIControlState.Normal)
                self.playVC.player?.pause()
                self.playing = false
                self.playButton.setImage(UIImage(named: "stationImage"), forState: UIControlState.Normal)
                self.playButton.hidden = false
            }
        }else{
            let soundPath = curVideo+"\(tmpSecond).acc"
            recording = false
            recorder?.stop()
            
            recorder = nil

            sender.setTitle("录音", forState: UIControlState.Normal)
            print(soundPath)
            allMessages![tmpSecond] = Message(type:1,second: tmpSecond,content: soundPath)
            self.playButton.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
            
        }
        
    }
    @IBOutlet weak var playVC: PlayVideoView!
    
    @IBOutlet weak var videoProgress: UIProgressView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playVideo(sender: UIButton) {
        if playing == false{
            playing = true
            sender.hidden = true
            sender.setImage(UIImage(named: "btn-pause"), forState: UIControlState.Normal)
            self.playVC.player?.play()
        }else{
            playing = false
            sender.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
            self.playVC.player?.pause()
        }
        
        
    }
    
    func catchTap(sender : UITapGestureRecognizer){
        playButton.hidden = !playButton.hidden
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let url:NSURL = NSURL(fileURLWithPath: Video.videoDirPath + curVideo)
        let player = AVPlayer(URL: url)
        self.playVC!.player = player
        let tap = UITapGestureRecognizer(target: self,action: #selector(EditVideoController.catchTap(_:)))
        self.playVC.addGestureRecognizer(tap)
        self.playVC.player?.addPeriodicTimeObserverForInterval(CMTimeMake(1,10), queue: dispatch_get_main_queue(), usingBlock: {(time:CMTime) in
            let currentTime = self.playVC.player!.currentTime;
            self.curSeconds = Int(currentTime().seconds*100)
            let totalTime = self.playVC.player!.currentItem!.duration;
            let progress = CMTimeGetSeconds(currentTime())/CMTimeGetSeconds(totalTime);
            self.videoProgress.progress = Float32(progress);
            if progress >= 1.0{
                self.playButton.hidden = false
                self.playButton.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
                self.playVC.player?.seekToTime(kCMTimeZero)
            }
        })
        
        //初始化录音器
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        //设置录音类型
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        //设置支持后台
        try! session.setActive(true)
        //初始化字典并添加设置参数
        recorderSeetingsDic =
            [
                AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
                AVNumberOfChannelsKey: 2, //录音的声道数，立体声为双声道
                AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
                AVEncoderBitRateKey : 320000,
                AVSampleRateKey : 44100.0 //录音器每秒采集的录音样本数
        ]
        self.allMessages = Message.loadMessage(curVideo)
        textDisappear()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.playVC.player?.pause()
        playing = false
        recording = false
        Message.storeMessage(curVideo, messageData: allMessages!)
    }
    
    
    @IBOutlet weak var textMessage: UITextView!

    @IBOutlet weak var textFinish: UIButton!
    @IBOutlet weak var textCancel: UIButton!
    
    @IBAction func textFinishPress(sender: UIButton) {
        textDisappear()
        allMessages![curSeconds] = Message(type:0,second: curSeconds,content: textMessage.text)
        textMessage.text = ""
    }
    @IBAction func textCancelPress(sender: UIButton) {
        textDisappear()
    }
    func textAppear(){
        textMessage.hidden = false
        textFinish.hidden = false
        textCancel.hidden = false
        textMessage.becomeFirstResponder()
        self.playVC.player?.pause()
        self.playing = false
        self.playButton.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
        self.playButton.hidden = false
    }
    func textDisappear(){
        textMessage.hidden = true
        textMessage.resignFirstResponder()
        textFinish.hidden = true
        textCancel.hidden = true
    }
    
    @IBAction func exitEdit(sender: AnyObject) {
         dismissViewControllerAnimated(true, completion: nil)
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
