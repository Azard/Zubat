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
    var tmpArrow:Arrow?
    var tmpRect:Rectangle?
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonPress(sender: UIButton) {
        if playing == false{
            playing = true
            sender.hidden = true
            sender.setImage(UIImage(named: "btn-pause"), forState: UIControlState.Normal)
            self.display.player?.play()
        }else{
            playing = false
            sender.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
            self.display.player?.pause()
        }
    }
    @IBOutlet weak var textOK: UIButton!
    
    @IBAction func textOKPress(sender: UIButton) {
        textDisappear()
        if let _:Arrow = tmpArrow{
            tmpArrow?.removeFromSuperview()
        }
        if let _:Rectangle = tmpRect{
            tmpRect?.removeFromSuperview()
        }
        player?.stop()
    }
    
    @IBOutlet weak var videoProgress: UIProgressView!
    @IBOutlet weak var textMessage: UITextView!
    @IBOutlet weak var messageTable: UITableView!
    var allMessages : [Int:Message]?
    var timeLine : [Int] = [Int]()
    var timeOrder : Int = 0
    var curSeconds : Int = 0
    @IBOutlet weak var display: PlayVideoView!
    
    func catchTap(sender : UITapGestureRecognizer){
        playButton.hidden = !playButton.hidden
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        messageTable.registerNib(cellNib, forCellReuseIdentifier: "NothingFound")
        
        // Setup TableView
        messageTable.backgroundColor = UIColor.clearColor()
        messageTable.backgroundView = nil
        messageTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.allMessages = Message.loadMessage(curVideo)
        self.timeLine = Array(self.allMessages!.keys).sort(<)
        print(timeLine)
        dispatch_async(dispatch_get_main_queue()){
            self.messageTable.reloadData()
            self.messageTable.setNeedsDisplay()
        }
        
        
        let url:NSURL = NSURL(fileURLWithPath: Video.videoDirPath + curVideo)
        let player = AVPlayer(URL: url)
        self.display!.player = player
        let tap = UITapGestureRecognizer(target: self,action: #selector(EditVideoController.catchTap(_:)))
        self.display.addGestureRecognizer(tap)
        self.display.player?.addPeriodicTimeObserverForInterval(CMTimeMake(1,10), queue: dispatch_get_main_queue(), usingBlock: {(time:CMTime) in
            let currentTime = self.display.player!.currentTime;
            self.curSeconds = Int(currentTime().seconds*100)
            self.displayMessage()
            let totalTime = self.display.player!.currentItem!.duration;
            let progress = CMTimeGetSeconds(currentTime())/CMTimeGetSeconds(totalTime);
            self.videoProgress.progress = Float32(progress);
            if progress >= 1.0{
                self.playButton.hidden = false
                self.playButton.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
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
    func displayMessage(){
        if(timeLine.count > 0 && timeLine.count > timeOrder){
            let line = timeLine[timeOrder]
            if self.curSeconds >= line && curSeconds - line <= 10{
                self.playing = false
                self.display.player?.pause()
                
                messageTable.selectRowAtIndexPath(NSIndexPath(forRow: timeOrder,inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                timeOrder = timeOrder + 1
                let m = allMessages![line]
                if(m?.type == 0){
                    textAppear((m?.content)!)
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
                    let xyArray = content.componentsSeparatedByString(",")
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
                    tmpArrow = arrow
                    self.view.addSubview(arrow);
                    
                }else if(m?.type == 3){
                    let content:String = (m?.content)!
                    let xyArray = content.componentsSeparatedByString(",")
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
                    tmpRect = rect
                    self.view.addSubview(rect);
                }
                self.playButton.setImage(UIImage(named: "btn-play"), forState: UIControlState.Normal)
                self.playButton.hidden = false
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
        textOK.hidden = false

        
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
        
        
            if timeLine.count == 0 {
                return 1
            } else {
                return timeLine.count
            }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if timeLine.isEmpty {
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
            
            let time = timeLine[indexPath.row]
            cell.configureMessageCell(allMessages![time]!)
            
            return cell
        }
        
    }
    
}
