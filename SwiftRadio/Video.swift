//
//  Video.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/16.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Video:NSObject{
    
    var videoName : String
    var videoDate : NSDate
    var videoDateToString : String
    var videoPath : String
    var previewImage : UIImage
    init(name:String , date:NSDate,image:UIImage){
        self.videoName = name
        self.videoDate = date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // Date 转 String
        videoDateToString = dateFormatter.stringFromDate(date)
        videoPath = Video.videoDirPath + name
        previewImage = image
    }
    
    static let videoDirPath:String = NSHomeDirectory() + "/Documents/video/"
    
    static let fileManager = NSFileManager.defaultManager()


    static func storeVideo(videoName : String,videoData : NSData)-> Bool{
        if !self.fileManager.fileExistsAtPath(self.videoDirPath) {
            do{try self.fileManager.createDirectoryAtPath(self.videoDirPath,withIntermediateDirectories: true, attributes: nil)}catch{}
        }
        
        return videoData.writeToFile(self.videoDirPath + videoName+".mp4", atomically: false)
        
    }
    
    static func listAllVideo()->[Video]{
        print("show all videos")
        
        var videos : [Video] = []
        var contents : [String] = []
        do{try contents = fileManager.contentsOfDirectoryAtPath(videoDirPath)}catch{}
        for content in contents{
            let v = videoDirPath+content
            var attrs : [String : AnyObject] = ["":""]//初始化
            do{
                attrs = try fileManager.attributesOfItemAtPath(v)
            }catch{print(error)}
            let date = attrs["NSFileCreationDate"] as! NSDate
            
            videos.append(Video(name: content,date: date,image: getPreviewImage(v)))
        }
    
        print("contents: \(contents)")
        return videos
        
    }
    static func getPreviewImage(videoPath:String)->UIImage{
        let url:NSURL = NSURL(fileURLWithPath: videoPath)
        
        let asset:AVURLAsset = AVURLAsset(URL:url, options: nil)
        
        let gen :AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        gen.appliesPreferredTrackTransform = true
        
        let time: CMTime = CMTimeMakeWithSeconds(0.0, 600)
        
        
        var actualTime:CMTime = CMTime()
        
        let image:CGImageRef = try! gen.copyCGImageAtTime(time, actualTime: &actualTime)
        
        let thumb:UIImage = UIImage(CGImage: image)
        
        return thumb;
    }
    func editVideo(){
        
    }
    static func deleteVideo(videoName : String){
        do{
            try fileManager.removeItemAtPath(videoDirPath+videoName)
        }catch{}
    }

}
