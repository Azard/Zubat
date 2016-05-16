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
    var recorder:AVAudioRecorder? //录音器
    var player:AVAudioPlayer? //播放器
    var recorderSeetingsDic:[String : AnyObject]? //录音器设置参数数组
    var curSeconds:Int = 0
    var allMessages : [Int:Message]?
    var color : Int = 1
    var scene : Scene = Scene(type: 0,sceneName: "")
    var allScenes : [Int : Scene]?
    var startingPoint : CGPoint = CGPoint(x: -1,y: -1)
    var endingPoint : CGPoint = CGPoint()
    var lineMessage : Bool = false
    var curveMessage : Bool = false
    var tmpMessages : [UIView] = []

    
    @IBOutlet weak var playVC: PlayVideoView!
    
    
    @IBOutlet weak var videoProgress: UISlider!

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    
    var homeMenuView:DWBubbleMenuButton?
    var mesMenuView:DWBubbleMenuButton?
    var colorMenuView:DWBubbleMenuButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        let url:NSURL = NSURL(fileURLWithPath: Video.videoDirPath + curVideo)
        let player = AVPlayer(URL: url)
        self.playVC!.player = player
//        let tap = UITapGestureRecognizer(target: self,action: #selector(EditVideoController.catchTap(_:)))
//        self.playVC.addGestureRecognizer(tap)
        self.playVC.player?.addPeriodicTimeObserverForInterval(CMTimeMake(1,10), queue: dispatch_get_main_queue(), usingBlock: {(time:CMTime) in
            let currentTime = self.playVC.player!.currentTime;
            self.curSeconds = Int(currentTime().seconds*100)
            let totalTime = self.playVC.player!.currentItem!.duration;
            let progress = CMTimeGetSeconds(currentTime())/CMTimeGetSeconds(totalTime);
            //self.videoProgress.progress = Float32(progress);
            if(!self.draging){
                self.videoProgress.setValue(Float32(progress), animated: true)
            }
            if progress >= 1.0{
            
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
        self.allScenes = Scene.loadScene(curVideo)
        textDisappear()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(EditVideoController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        videoProgress.minimumValue = 0
        videoProgress.maximumValue = 1
        videoProgress.addTarget(self,action:#selector(EditVideoController.sliderDidchange(_:)), forControlEvents:UIControlEvents.ValueChanged)
        videoProgress.addTarget(self,action:#selector(EditVideoController.sliderDragUp(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        var homeLabel =  self.createHomeButtonView("Home")
        homeMenuView = DWBubbleMenuButton(frame:CGRectMake(mainLabel.frame.origin.x+30,mainLabel.frame.origin.y+100,mainLabel.frame.width,mainLabel.frame.height))
        homeMenuView!.homeButtonView = homeLabel
        var contentArr = ["有声","无声","完成","暂停","播放","OK"]
        homeMenuView!.addButtons(self.createDemoButtonArray(0,arr:contentArr))
        self.view.addSubview(homeMenuView!)
        
        
        homeLabel =  self.createHomeButtonView("Mes")
        mesMenuView = DWBubbleMenuButton(frame:CGRectMake(messageLabel.frame.origin.x+30,messageLabel.frame.origin.y+100,messageLabel.frame.width,messageLabel.frame.height))
        mesMenuView!.homeButtonView = homeLabel
        contentArr = ["矩形","直线","箭头","曲线","文本"]
        mesMenuView!.addButtons(self.createDemoButtonArray(10,arr:contentArr))
        self.view.addSubview(mesMenuView!)
        
        homeLabel =  self.createHomeButtonView("Color")
        
        colorMenuView = DWBubbleMenuButton(frame:CGRectMake(colorLabel.frame.origin.x+30,colorLabel.frame.origin.y+100,colorLabel.frame.width,colorLabel.frame.height))
        colorMenuView!.homeButtonView = homeLabel
        contentArr = ["红色","黑色","黄色","蓝色"]
        colorMenuView!.addButtons(self.createDemoButtonArray(20,arr:contentArr))
        self.view.addSubview(colorMenuView!)

        
    }
    func createHomeButtonView(str:String) -> UILabel {
        
        let label = UILabel(frame: CGRectMake(0.0, 0.0, 50.0, 50.0))
        
        label.text = str;
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.layer.cornerRadius = label.frame.size.height / 2.0;
        label.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:0.5)
        label.clipsToBounds = true;
        
        return label;
    }
    func createDemoButtonArray(type:Int,arr:[String]) -> [UIButton] {
        var buttons:[UIButton]=[]
        var i = 0
        for str in arr {
            let button:UIButton = UIButton(type: UIButtonType.System)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitle(str, forState: UIControlState.Normal)
            
            button.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
            button.layer.cornerRadius = button.frame.size.height / 2.0;
            button.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
            button.clipsToBounds = true;
            i += 1
            button.tag = type + i;
            button.addTarget(self, action: #selector(self.buttonTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            buttons.append(button)
            
        }
        return buttons
        
    }
    func buildScene(type:Int){
        self.playVC.player?.pause()
        let alertController = UIAlertController(title: "Scene", message: "input the name of the scene", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "scene name"
        }
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) -> Void in
            let tmp = (alertController.textFields?.first)! as UITextField
            self.scene.sceneName = tmp.text!
            self.scene.type = type
            self.scene.startTime = self.curSeconds
            self.allScenes![self.curSeconds] = self.scene
            if(type == 0){
                let soundPath = self.curVideo+"_"+self.scene.sceneName+".acc"
                
                let session:AVAudioSession = AVAudioSession.sharedInstance()
                //设置录音类型
                try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                //设置支持后台
                try! session.setActive(true)
                
                self.recorder = try! AVAudioRecorder(URL: NSURL(string: Message.soundDirPath + soundPath)!,settings: self.recorderSeetingsDic!)
                if self.recorder != nil {
                    self.recorder!.meteringEnabled = true
                    self.recorder!.prepareToRecord()
                    self.recorder!.record()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "cancle", style: UIAlertActionStyle.Cancel){
            (action:UIAlertAction!) -> Void in
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func buttonTap(sender:UIButton){
        switch sender.tag {
        case 1:
            buildScene(0)
            print("Button tapped, tag:\(sender.tag)")
        case 2:
            buildScene(1)
            print("Button tapped, tag:\(sender.tag)")
        case 3:
            completeScene()
            print("Button tapped, tag:\(sender.tag)")
        case 4:
            self.playVC.player?.pause()
            print("Button tapped, tag:\(sender.tag)")
        case 5:
            self.playVC.player?.play()
            print("Button tapped, tag:\(sender.tag)")
        case 6:
            completeMessage()
            print("Button tapped, tag:\(sender.tag)")
        case 11:
            self.rectMessage = true
            self.arrowMessage = false
            self.curveMessage = false
            self.lineMessage = false
            print("Button tapped, tag:\(sender.tag)")
        case 12:
            self.rectMessage = false
            self.arrowMessage = false
            self.curveMessage = false
            self.lineMessage = true
            print("Button tapped, tag:\(sender.tag)")
        case 13:
            self.rectMessage = false
            self.arrowMessage = true
            self.curveMessage = false
            self.lineMessage = false
            print("Button tapped, tag:\(sender.tag)")
        case 14:
            self.rectMessage = false
            self.arrowMessage = false
            self.curveMessage = true
            self.lineMessage = false
            print("Button tapped, tag:\(sender.tag)")
        case 15:
            textAppear()
            print("Button tapped, tag:\(sender.tag)")
        case 21:
            self.color = 1
            print("Button tapped, tag:\(sender.tag)")
        case 22:
            self.color = 2
            print("Button tapped, tag:\(sender.tag)")
        case 23:
            self.color = 3
            print("Button tapped, tag:\(sender.tag)")
        case 24:
            self.color = 4
            print("Button tapped, tag:\(sender.tag)")
        
        default:
            print("Button tapped, tag:\(sender.tag)")
        }
    }
    
    
    var draging = false
    func sliderDidchange(slider:UISlider){
        
        draging = true
    }
    func sliderDragUp(sender: UISlider) {
        draging = false
        let totalTime = self.playVC.player!.currentItem!.duration
        let time = Int64(Float(totalTime.value)*sender.value)
        
//        let curTime =  CMTime(value: time,timescale: totalTime.timescale,flags:totalTime.flags,epoch:totalTime.epoch)
        let curTime = CMTimeMake(time, totalTime.timescale)
        self.playVC.player?.seekToTime(curTime)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.playVC.player?.pause()
//        playing = false
//        recording = false
        Message.storeMessage(curVideo, messageData: allMessages!)
        Scene.storeScene(curVideo, sceneData: allScenes!)
        
    }
    
    
    @IBOutlet weak var textMessage: UITextView!

    @IBOutlet weak var textFinish: UIButton!
    @IBOutlet weak var textCancel: UIButton!
    
    @IBAction func textFinishPress(sender: UIButton) {
        textDisappear()
        allMessages![curSeconds] = Message(type:0,second: curSeconds,content: textMessage.text,scene:scene.sceneName)
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
    }
    func textDisappear(){
        textMessage.hidden = true
        textMessage.resignFirstResponder()
        textFinish.hidden = true
        textCancel.hidden = true
    }
    
    var tmpArrow:Arrow?
    var tmpRect:Rectangle?
    var tmpLine:SLine?
    var tmpCurve:CurveLine?
    var arrowMessage:Bool = false
    
    var rectMessage:Bool = false
    
    var minX:CGFloat = 10000
    var minY:CGFloat = 10000
    var maxX:CGFloat = 0
    var maxY:CGFloat = 0
    var curvePoints : [CGPoint] = []
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
                arrow.color = self.color
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
                rect.color = self.color
                tmpRect = rect
                self.view.addSubview(rect);
            }

        }else if(curveMessage){
            if(location.x < minX){
                minX = location.x
            }
            if(location.x > maxX){
                maxX = location.x
            }
            if(location.y < minY){
                minY = location.y
            }
            if(location.y > maxY){
                maxY = location.y
            }
            curvePoints.append(location)
            if(startingPoint.x < 0){
                startingPoint = location
            }else{
                let width = maxX - minX + 5
                let height = maxY - minY + 5
                let viewRect = CGRect(x: minX, y: minY, width: width, height: height)
                if let _:CurveLine = tmpCurve{
                    tmpCurve?.removeFromSuperview()
                }
                let line = CurveLine(frame: viewRect)
                line.color = self.color
                line.passingValues(curvePoints,minX: minX,minY:minY)
                tmpCurve = line
                self.view.addSubview(line)
            }
        }else if(lineMessage){
            if(startingPoint.x < 0){
                startingPoint = location
            }else{
                endingPoint = location
                let x = min(startingPoint.x,endingPoint.x)
                let y = min(startingPoint.y,endingPoint.y)
                let width = max(endingPoint.x-startingPoint.x,startingPoint.x-endingPoint.x)
                let height = max(endingPoint.y-startingPoint.y,startingPoint.y-endingPoint.y)
                let viewRect = CGRect(x: x, y: y, width: width, height: height)
                if let _:SLine = tmpLine{
                    tmpLine?.removeFromSuperview()
                }
                let line = SLine(frame: viewRect)
                line.color = self.color
                line.passingValues(CGPoint(x: startingPoint.x-x,y: startingPoint.y-y), endingPointValue: CGPoint(x: endingPoint.x-x,y: endingPoint.y-y))
                tmpLine = line
                self.view.addSubview(line);
            }
        }
        //print("(\(location.x),\(location.y))")
        
    }
    func completeMessage() {
        if(arrowMessage){
            let content = "\(self.color)|\(startingPoint.x),\(startingPoint.y),\(endingPoint.x),\(endingPoint.y)"
            allMessages![curSeconds] = Message(type:2,second: curSeconds,content: content,scene:scene.sceneName)
            startingPoint = CGPoint(x: -1,y: -1)
            tmpMessages.append(tmpArrow!)
            self.arrowMessage = false
            self.tmpArrow = nil
        }else if(rectMessage){
            let content = "\(self.color)|\(startingPoint.x),\(startingPoint.y),\(endingPoint.x),\(endingPoint.y)"
            allMessages![curSeconds] = Message(type:3,second: curSeconds,content: content,scene:scene.sceneName)
            startingPoint = CGPoint(x: -1,y: -1)
            tmpMessages.append(tmpRect!)
            self.rectMessage = false
            self.tmpRect = nil
        }else if(curveMessage){
            var content = "\(self.color)|\(minX)|\(minY)|\(maxX)|\(maxY)"
            for p in curvePoints{
                content = content + "|\(p.x),\(p.y)"
            }
            allMessages![curSeconds] = Message(type:5,second: curSeconds,content: content,scene:scene.sceneName)
            startingPoint = CGPoint(x: -1,y: -1)
            tmpMessages.append(tmpCurve!)
            self.curveMessage = false
            self.tmpCurve = nil
        }else if(lineMessage){
            let content = "\(self.color)|\(startingPoint.x),\(startingPoint.y),\(endingPoint.x),\(endingPoint.y)"
            allMessages![curSeconds] = Message(type:4,second: curSeconds,content: content,scene:scene.sceneName)
            startingPoint = CGPoint(x: -1,y: -1)
            tmpMessages.append(tmpLine!)
            self.lineMessage = false
            self.tmpLine = nil
        }
        
        self.view.bringSubviewToFront(homeMenuView!)
        self.view.bringSubviewToFront(mesMenuView!)
        self.view.bringSubviewToFront(colorMenuView!)
    }
    func completeScene(){
        self.playVC.player?.pause()
        while tmpMessages.count > 0 {
            let tmp = tmpMessages.last
            tmp?.removeFromSuperview()
            tmpMessages.removeLast()
        }
        scene.endTime = curSeconds
        
    }
    
//    
//    @IBAction func exitEdit(sender: AnyObject) {
//         dismissViewControllerAnimated(true, completion: nil)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
