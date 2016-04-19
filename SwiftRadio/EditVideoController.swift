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
    var startingPoint : CGPoint = CGPoint(x: -1,y: -1)
    var endingPoint : CGPoint = CGPoint()

    
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
            //print(Message.soundDirPath + soundPath)
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
                //sender.setTitle("完成", forState: UIControlState.Normal)
                sender.setImage(UIImage(named: "complete"), forState: UIControlState.Normal)
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

            //sender.setTitle("录音", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "audiorecorder"), forState: UIControlState.Normal)
            //print(soundPath)
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
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(EditVideoController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
        
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
    func stopVideo()  {
        self.playVC.player?.pause()
        self.playing = false
        self.playButton.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
        self.playButton.hidden = false

    }
    func textAppear(){
        textMessage.hidden = false
        textFinish.hidden = false
        textCancel.hidden = false
        textMessage.becomeFirstResponder()
        stopVideo()
    }
    func textDisappear(){
        textMessage.hidden = true
        textMessage.resignFirstResponder()
        textFinish.hidden = true
        textCancel.hidden = true
    }
    
    var tmpArrow:Arrow?
    var tmpRect:Rectangle?
    var arrowMessage:Bool = false
    @IBAction func arrowMessagePress(sender: UIButton) {
        if(arrowMessage){
            //sender.setTitle("箭头", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "arrow"), forState: UIControlState.Normal)
            arrowMessage = false
            let content = "\(startingPoint.x),\(startingPoint.y),\(endingPoint.x),\(endingPoint.y)"
            allMessages![curSeconds] = Message(type:2,second: curSeconds,content: content)
            tmpArrow?.removeFromSuperview()
            startingPoint = CGPoint(x: -1,y: -1)
        }else{
            //sender.setTitle("完成", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "complete"), forState: UIControlState.Normal)
            arrowMessage = true
            stopVideo()
        }
        
    }
    
    var rectMessage:Bool = false
    @IBAction func rectMessagePress(sender: UIButton) {
        if(rectMessage){
            //sender.setTitle("矩形", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "rectangle"), forState: UIControlState.Normal)
            rectMessage = false
            let content = "\(startingPoint.x),\(startingPoint.y),\(endingPoint.x),\(endingPoint.y)"
            print(content)
            allMessages![curSeconds] = Message(type:3,second: curSeconds,content: content)
            tmpRect?.removeFromSuperview()
            startingPoint = CGPoint(x: -1,y: -1)
        }else{
            //sender.setTitle("完成", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "complete"), forState: UIControlState.Normal)
            rectMessage = true
            stopVideo()
        }
    }
    
    
    func handlePanGesture(sender: UIPanGestureRecognizer){
        //得到拖的过程中的xy坐标
        //let translation : CGPoint = sender.velocityInView(canvasView)
        var location : CGPoint = sender.locationInView(playVC)
        location.y = location.y + 50
        if(arrowMessage){
            if(startingPoint.x < 0){
                startingPoint = location
            }else{
                endingPoint = location
                let x = min(startingPoint.x,endingPoint.x)
                let y = min(startingPoint.y,endingPoint.y)
                let width = max(endingPoint.x-startingPoint.x,startingPoint.x-endingPoint.x)
                let height = max(endingPoint.y-startingPoint.y,startingPoint.y-endingPoint.y)
                let viewRect = CGRect(x: x-5, y: y-5, width: width+5, height: height+5)
                if let _:Arrow = tmpArrow{
                    tmpArrow?.removeFromSuperview()
                }
                let arrow = Arrow(frame: viewRect)
                arrow.passingValues(CGPoint(x: startingPoint.x-x,y: startingPoint.y-y), endingPointValue: CGPoint(x: endingPoint.x-x,y: endingPoint.y-y))
                tmpArrow = arrow

                self.view.addSubview(arrow);
            }
        }else if(rectMessage){
            if(startingPoint.x < 0){
                startingPoint = location
            }else{
                endingPoint = location
                let x = min(startingPoint.x,endingPoint.x)
                let y = min(startingPoint.y,endingPoint.y)
                let width = max(endingPoint.x-startingPoint.x,startingPoint.x-endingPoint.x)
                let height = max(endingPoint.y-startingPoint.y,startingPoint.y-endingPoint.y)
                let viewRect = CGRect(x: x, y: y, width: width, height: height)
                if let _:Rectangle = tmpRect{
                    tmpRect?.removeFromSuperview()
                }
                let rect = Rectangle(frame: viewRect)
                tmpRect = rect
                self.view.addSubview(rect);
            }

        }
        //print("(\(location.x),\(location.y))")
        
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
