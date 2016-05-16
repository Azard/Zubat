//
//  Message.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/24.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import Foundation

class Message{
    var type : Int//0代表文字，1代表声音,2代表箭头，3代表矩形,4代表直线，5代表曲线
    var second : Int//这里second代表百分之一秒
    var timeStamp : String
    var sceneName :String
    var content:String
    init(type:Int,second:Int,content:String,scene:String){
        self.type = type
        self.second = second
        self.sceneName = scene
        let tmp = second/100
        let h = tmp/3600
        let m = (tmp%3600)/60
        let s = tmp%60
        timeStamp = "\(h):\(m):\(s).\(second%100)"
        self.content = content
    }
    static let mesDirPath:String = NSHomeDirectory() + "/Documents/message/"
    static let soundDirPath:String = NSHomeDirectory() + "/Documents/sound/"
    
    static let fileManager = NSFileManager.defaultManager()
    static func storeMessage(videoName : String,messageData : [Int:Message])-> Bool{
        if !self.fileManager.fileExistsAtPath(self.mesDirPath) {
            do{try self.fileManager.createDirectoryAtPath(self.mesDirPath,withIntermediateDirectories: true, attributes: nil)}catch{}
        }
        if !self.fileManager.fileExistsAtPath(self.soundDirPath) {
            do{try self.fileManager.createDirectoryAtPath(self.soundDirPath,withIntermediateDirectories: true, attributes: nil)}catch{}
        }
        var tmp : [Int:[String]]=Dictionary()
        for mes in (messageData.keys){
            let m = messageData[mes];
            tmp[mes] = ["\(m!.type)","\(m!.second)",m!.content,m!.sceneName]
        }
        let sortedKeys = Array(tmp.keys).sort(<)
        var array:[[String]] = []
        for key in sortedKeys{
            array.append(tmp[key]!)
        }
        //print(array)
        let nsarray = array as NSArray
        return nsarray.writeToFile(self.mesDirPath + videoName + ".plist", atomically: false)
        
    }
    
    static func loadMessage(videoName : String)->[Int:Message]{
        var allMessages : [Int:Message] = Dictionary()
        if self.fileManager.fileExistsAtPath(self.mesDirPath + videoName + ".plist") {
            let arrays = NSArray(contentsOfFile: self.mesDirPath + videoName + ".plist") as! [[String]]
            for a in arrays{
                allMessages[Int(a[1])!] = Message(type: Int(a[0])!,second: Int(a[1])!,content: a[2],scene:a[3])
            }
        }
//        var contents:[String] = []
//        do{try contents = fileManager.contentsOfDirectoryAtPath(soundDirPath)}catch{}
////        for content in contents{
////            print(content)
////        }

        return allMessages
    }
    
}
