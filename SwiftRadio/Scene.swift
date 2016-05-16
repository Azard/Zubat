//
//  Scene.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/5/10.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import Foundation

class Scene{
    var type : Int //0代表不保留原声，1代表保留原声
    var sceneName : String
    var startTime : Int!
    var endTime : Int!
    init(type : Int,sceneName:String){
        self.type = type
        self.sceneName = sceneName
    }
    init(type:Int,sceneName:String,start:Int,end:Int){
        self.type = type
        self.sceneName = sceneName
        self.startTime = start
        self.endTime = end
    }
    static let sceneDirPath:String = NSHomeDirectory() + "/Documents/scene/"

    static let fileManager = NSFileManager.defaultManager()
    static func storeScene(videoName : String,sceneData : [Int:Scene])-> Bool{
        if !self.fileManager.fileExistsAtPath(self.sceneDirPath) {
            do{try self.fileManager.createDirectoryAtPath(self.sceneDirPath,withIntermediateDirectories: true, attributes: nil)}catch{}
        }

        var tmp : [Int:[String]]=Dictionary()
        for mes in (sceneData.keys){
            let m = sceneData[mes];
            tmp[mes] = ["\(m!.type)",m!.sceneName,"\(m!.startTime)","\(m!.endTime)"]
        }
        let sortedKeys = Array(tmp.keys).sort(<)
        var array:[[String]] = []
        for key in sortedKeys{
            array.append(tmp[key]!)
        }
        print(array)
        let nsarray = array as NSArray
        return nsarray.writeToFile(self.sceneDirPath + videoName + ".plist", atomically: false)
        
    }
    
    static func loadScene(videoName : String)->[Int:Scene]{
        var allScenes : [Int:Scene] = Dictionary()
        if self.fileManager.fileExistsAtPath(self.sceneDirPath + videoName + ".plist") {
            let arrays = NSArray(contentsOfFile: self.sceneDirPath + videoName + ".plist") as! [[String]]
            for a in arrays{
                allScenes[Int(a[2])!] = Scene(type: Int(a[0])!,sceneName: a[1],start: Int(a[2])!,end: Int(a[3])!)
            }
        }
        //        var contents:[String] = []
        //        do{try contents = fileManager.contentsOfDirectoryAtPath(soundDirPath)}catch{}
        ////        for content in contents{
        ////            print(content)
        ////        }
        
        return allScenes
    }

    
}
