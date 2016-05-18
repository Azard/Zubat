//
//  DisplayController.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/25.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
class DisplayController: UIViewController {
    var curVideo = ""
    var playing : Bool = false
    var player:AVAudioPlayer? //播放器
    var tmpMessages : [UIView] = []
    @IBOutlet weak var jumpButton: UIBarButtonItem!
    @IBAction func jumpMessage(sender: UIBarButtonItem) {
        if playing == false{
            playing = true
            sender.image = UIImage(named: "btn-pause")
            if(curScene?.type == 0){
                self.display.player?.volume = 0
            }else{
                self.display.player?.volume = 1
            }
            self.display.player?.play()
            if(curScene?.type == 0){
                self.player?.play()
            }
            textDisappear()
        }else{
            playing = false
            sender.image = UIImage(named: "btn-play")
            self.display.player?.pause()
            
            if(curScene?.type == 0){
                self.player?.pause()
            }
        }
    }
    
    @IBOutlet weak var videoProgress: UIProgressView!
    @IBOutlet weak var textMessage: UITextView!
    @IBOutlet weak var messageTable: UITableView!
    var allMessages : [Int:Message]?
    var allScenes : [Int:Scene]?
    var curScene : Scene?
    
    var timeLine : [Int] = [Int]()
    var timeOrder : Int = 0
    var curSeconds : Int = 0
    var sceneLine : [Int] = [Int]()
    var sceneOrder : Int = 0
    @IBOutlet weak var display: PlayVideoView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTable.delegate = self
        let cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        messageTable.registerNib(cellNib, forCellReuseIdentifier: "NothingFound")
        
        // Setup TableView
        messageTable.backgroundColor = UIColor.clearColor()
        messageTable.backgroundView = nil
        messageTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.allMessages = Message.loadMessage(curVideo)
        self.allScenes = Scene.loadScene(curVideo)
        self.timeLine = Array(self.allMessages!.keys).sort(<)
        self.sceneLine = Array(self.allScenes!.keys).sort(<)
        
        print(timeLine)
        dispatch_async(dispatch_get_main_queue()){
            self.messageTable.reloadData()
            self.messageTable.setNeedsDisplay()
        }
        
        
        let url:NSURL = NSURL(fileURLWithPath: Video.videoDirPath + curVideo)
        let player = AVPlayer(URL: url)
        self.display!.player = player
        if(sceneLine.count > 0){
            curScene = allScenes![sceneLine[0]]
            messageTable.selectRowAtIndexPath(NSIndexPath(forRow: 0,inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
//            let totalTime = self.display.player!.currentItem!.duration
//            print(totalTime)
//            print(curScene?.startTime)
//            let curTime = CMTimeMake(Int64((curScene?.startTime)!)/100, totalTime.timescale)
//            self.display.player?.seekToTime(curTime)
//            if(curScene?.type == 0){
//                let soundPath = self.curVideo+"_"+self.curScene!.sceneName+".acc"
//                self.player = try! AVAudioPlayer(contentsOfURL: NSURL(string : Message.soundDirPath + soundPath)!)
//                //player = try! AVAudioPlayer(contentsOfURL: NSURL(string: Message.soundDirPath+(m?.content)!)!)
//                if self.player == nil {
//                    print("播放失败")
//                }
////                else{
////                    self.player?.play()
////                }
//            }
        }else{
            curScene = Scene(type:1,sceneName:"",start:0,end:0)
        }
        self.display.player?.addPeriodicTimeObserverForInterval(CMTimeMake(1,10), queue: dispatch_get_main_queue(), usingBlock: {(time:CMTime) in
            let currentTime = self.display.player!.currentTime;
            self.curSeconds = Int(currentTime().seconds*100)
            self.displayScene()
            self.displayMessage()
            let totalTime = self.display.player!.currentItem!.duration;
            let progress = CMTimeGetSeconds(currentTime())/CMTimeGetSeconds(totalTime);
            self.videoProgress.progress = Float32(progress);
            if progress >= 1.0{

                self.timeOrder = 0
                self.display.player?.seekToTime(kCMTimeZero)
            }
        })
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        textDisappear()
        // Do any additional setup after loading the view.
    }
    func displayScene(){
        if(sceneLine.count > 0 && sceneLine.count > sceneOrder){
            
            if(curSeconds > curScene?.endTime){
                while tmpMessages.count > 0 {
                    let tmp = tmpMessages.last
                    tmp?.removeFromSuperview()
                    tmpMessages.removeLast()
                }
                sceneOrder = sceneOrder + 1
                if(sceneLine.count > sceneOrder){
                    curScene = allScenes![sceneLine[sceneOrder]]
                    messageTable.selectRowAtIndexPath(NSIndexPath(forRow: sceneOrder,inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                    var index = 0
                    for index = 0;index < timeLine.count;{
                        let line = timeLine[index]
                        if(line > curScene?.startTime){
                            self.timeOrder = index
                            break
                        }
                        index = index + 1
                    }

                    let totalTime = self.display.player!.currentItem!.duration
                    let ratio:Double = Double((curScene?.startTime)!)/(totalTime.seconds*100.0)
                    let time = Int64(Double(totalTime.value)*ratio)
                    print(totalTime.seconds*100)
                    print(curScene?.startTime)
                    let curTime = CMTimeMake(time, totalTime.timescale)
                    self.display.player?.seekToTime(curTime)
                    self.display.player?.pause()
                    jumpButton.image = UIImage(named: "btn-play")
                    playing = false
                    if(curScene?.type == 0){
                        let soundPath = self.curVideo+"_"+self.curScene!.sceneName+".acc"
                        print(Message.soundDirPath + soundPath)
                        self.player = try! AVAudioPlayer(contentsOfURL: NSURL(string : Message.soundDirPath + soundPath)!)
                        if self.player == nil {
                            print("播放失败")
                        }
                    }
                }else{
                    self.display.player?.pause()
                    playing = false
                    jumpButton.image = UIImage(named: "btn-play")
                }
            }
        }else{
            self.display.player?.pause()
            playing = false
            jumpButton.image = UIImage(named: "btn-play")
        }
    }
    func displayMessage(){
        if(timeLine.count > 0 && timeLine.count > timeOrder){
            let line = timeLine[timeOrder]
            if self.curSeconds >= line && curSeconds - line <= 10{
//                self.playing = false
//                self.display.player?.pause()
                
                
                timeOrder = timeOrder + 1
                let m = allMessages![line]
                if(m?.sceneName != curScene?.sceneName){
                    return
                }
                if(m?.type == 0){
                    textAppear((m?.content)!)
                    playing = false
                    jumpButton.image = UIImage(named: "btn-play")
                    self.display.player?.pause()
                    if(curScene?.type == 0){
                        self.player?.pause()
                    }
                }else if(m?.type == 1){
                    //let docDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                    //.UserDomainMask, true)[0]
                    print(Message.soundDirPath + (m?.content)!)
                    player = try! AVAudioPlayer(contentsOfURL: NSURL(string : Message.soundDirPath + (m?.content)!)!)
                    //player = try! AVAudioPlayer(contentsOfURL: NSURL(string: Message.soundDirPath+(m?.content)!)!)
                    if player == nil {
                        print("播放失败")
                    }else{
                        player?.play()
                    }
                }else if(m?.type == 2){
                    let content:String = (m?.content)!
                    let contentArray = content.componentsSeparatedByString("|")
                    let color = Int(contentArray[0])!
                    let xyArray = contentArray[1].componentsSeparatedByString(",")
                    
                    let x1 = CGFloat(Float(xyArray[0])!)
                    let y1 = CGFloat(Float(xyArray[1])!)
                    let x2 = CGFloat(Float(xyArray[2])!)
                    let y2 = CGFloat(Float(xyArray[3])!)
                    let startingPoint = CGPoint(x:x1,y:y1)
                    let endingPoint = CGPoint(x:x2,y:y2)
                    let x = min(startingPoint.x,endingPoint.x)
                    let y = min(startingPoint.y,endingPoint.y)
                    let width = max(endingPoint.x-startingPoint.x,startingPoint.x-endingPoint.x)
                    let height = max(endingPoint.y-startingPoint.y,startingPoint.y-endingPoint.y)
                    let viewRect = CGRect(x: x-5, y: y-5, width: width+5, height: height+5)
                   
                    let arrow = Arrow(frame: viewRect)
                    arrow.passingValues(CGPoint(x: startingPoint.x-x,y: startingPoint.y-y), endingPointValue: CGPoint(x: endingPoint.x-x,y: endingPoint.y-y))
                    arrow.color = color
                    tmpMessages.append(arrow)
                    self.view.addSubview(arrow);
                    
                }else if(m?.type == 3){
                    let content:String = (m?.content)!
                    let contentArray = content.componentsSeparatedByString("|")
                    let color = Int(contentArray[0])!
                    let xyArray = contentArray[1].componentsSeparatedByString(",")
                    let x1 = CGFloat(Float(xyArray[0])!)
                    let y1 = CGFloat(Float(xyArray[1])!)
                    let x2 = CGFloat(Float(xyArray[2])!)
                    let y2 = CGFloat(Float(xyArray[3])!)
                    print(x1,y1,x2,y2)
                    let startingPoint = CGPoint(x:x1,y:y1)
                    let endingPoint = CGPoint(x:x2,y:y2)
                    let x = min(startingPoint.x,endingPoint.x)
                    let y = min(startingPoint.y,endingPoint.y)
                    let width = max(endingPoint.x-startingPoint.x,startingPoint.x-endingPoint.x)
                    let height = max(endingPoint.y-startingPoint.y,startingPoint.y-endingPoint.y)
                    let viewRect = CGRect(x: x, y: y, width: width, height: height)
                    
                    let rect = Rectangle(frame: viewRect)
                    rect.color = color
                    tmpMessages.append(rect)
                    self.view.addSubview(rect);
                }else if(m?.type == 4){
                    let content:String = (m?.content)!
                    let contentArray = content.componentsSeparatedByString("|")
                    let color = Int(contentArray[0])!
                    let xyArray = contentArray[1].componentsSeparatedByString(",")
                    let x1 = CGFloat(Float(xyArray[0])!)
                    let y1 = CGFloat(Float(xyArray[1])!)
                    let x2 = CGFloat(Float(xyArray[2])!)
                    let y2 = CGFloat(Float(xyArray[3])!)
                    print(x1,y1,x2,y2)
                    let startingPoint = CGPoint(x:x1,y:y1)
                    let endingPoint = CGPoint(x:x2,y:y2)
                    let x = min(startingPoint.x,endingPoint.x)
                    let y = min(startingPoint.y,endingPoint.y)
                    let width = max(endingPoint.x-startingPoint.x,startingPoint.x-endingPoint.x)
                    let height = max(endingPoint.y-startingPoint.y,startingPoint.y-endingPoint.y)
                    let viewRect = CGRect(x: x, y: y, width: width, height: height)
                    let line = SLine(frame: viewRect)
                    line.color = color
                    line.passingValues(CGPoint(x: startingPoint.x-x,y: startingPoint.y-y), endingPointValue: CGPoint(x: endingPoint.x-x,y: endingPoint.y-y))
                    tmpMessages.append(line)
                    self.view.addSubview(line);

                }else if(m?.type == 5){
                    let content:String = (m?.content)!
                    let contentArray = content.componentsSeparatedByString("|")
                    let color = Int(contentArray[0])!
                    var curvePoints : [CGPoint] = []
                    let minX:CGFloat = CGFloat(Float(contentArray[1])!)
                    let minY:CGFloat = CGFloat(Float(contentArray[2])!)
                    let maxX:CGFloat = CGFloat(Float(contentArray[3])!)
                    let maxY:CGFloat = CGFloat(Float(contentArray[4])!)
                    var index = 5
                    while index<contentArray.count {
                        let xyArray = contentArray[index].componentsSeparatedByString(",")
                        let x = CGFloat(Float(xyArray[0])!)
                        let y = CGFloat(Float(xyArray[1])!)
                        curvePoints.append(CGPoint(x:x,y:y))
                        index = index + 1

                    }
                    let width = maxX - minX + 5
                    let height = maxY - minY + 5
                    let viewRect = CGRect(x: minX, y: minY, width: width, height: height)

                    let line = CurveLine(frame: viewRect)
                    line.color = color
                    line.passingValues(curvePoints,minX: minX,minY:minY)
                    tmpMessages.append(line)
                    self.view.addSubview(line)
                    
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textAppear(content : String){
        textMessage.hidden = false
        textMessage.text = content
        textMessage.editable = false

    }
    func textDisappear(){
        textMessage.hidden = true
        //textMessage.resignFirstResponder()
        
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
extension DisplayController: UITableViewDataSource {
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
            if sceneLine.count == 0 {
                return 1
            } else {
                return sceneLine.count
            }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if sceneLine.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("NothingFound", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageTableViewCell
            
            // alternate background color
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor.clearColor()
            } else {
                cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            }
            
            let time = sceneLine[indexPath.row]
            cell.configureMessageCell(allScenes![time]!)
            
            return cell
        }
        
    }
    
}
extension DisplayController:UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        curScene = allScenes![sceneLine[indexPath.row]]
        sceneOrder = indexPath.row
        messageTable.selectRowAtIndexPath(NSIndexPath(forRow: indexPath.row,inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        let totalTime = self.display.player!.currentItem!.duration
        let ratio:Double = Double((curScene?.startTime)!)/(totalTime.seconds*100.0)
        let time = Int64(Double(totalTime.value)*ratio)
        print(totalTime.seconds*100)
        print(curScene?.startTime)
        let curTime = CMTimeMake(time, totalTime.timescale)
        self.display.player?.seekToTime(curTime)
        if(curScene?.type == 0){
            let soundPath = self.curVideo+"_"+self.curScene!.sceneName+".acc"
            self.player = try! AVAudioPlayer(contentsOfURL: NSURL(string : Message.soundDirPath + soundPath)!)
            //player = try! AVAudioPlayer(contentsOfURL: NSURL(string: Message.soundDirPath+(m?.content)!)!)
            if self.player == nil {
                print("播放失败")
            }
        }
        var index = 0
        for index = 0;index < timeLine.count;{
            let line = timeLine[index]
            if(line > curScene?.startTime){
                self.timeOrder = index
                break
            }
            index = index + 1
        }

    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView,editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            let time = self.sceneLine[indexPath.row]
            let scene = self.allScenes![time]!
            self.sceneLine.removeAtIndex(indexPath.row)
            self.allScenes?.removeValueForKey(time)
            if(scene.type == 0){
                do{
                    try Message.fileManager.removeItemAtPath(Message.soundDirPath +  self.curVideo+"_"+scene.sceneName+".acc")
                    
                }catch{}
            }
            Scene.storeScene(self.curVideo, sceneData: self.allScenes!)
            
            self.messageTable.reloadData()
        }
        delete.backgroundColor = UIColor.redColor()
        
        
        
        return [delete]
    }
}
