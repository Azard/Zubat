//
//  ViewController.swift
//  TakeVideo
//
//  Created by guoyanchang on 16/3/11.
//  Copyright © 2016年 guoyanchang. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary
import AVKit
import AVFoundation
import Foundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    var controller = UIImagePickerController()
    var assetsLibrary = ALAssetsLibrary()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    let videoDirPath:String = NSHomeDirectory() + "/Documents/video/"
    let soundDirPath:String = NSHomeDirectory() + "/Documents/sound/"
    let confDirPath:String = NSHomeDirectory() + "/Documents/conf/"
    
    let fileManager = NSFileManager.defaultManager()

    @IBAction func takeVideo(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.videoQuality = .TypeHigh
                imagePicker.delegate = self
                //self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                self.presentViewController(imagePicker, animated: true, completion: {print("camera completed")})
            } else {
                postAlert("Rear camera doesn't exist", message: "Application cannot access the camera.")
            }
        } else {
            postAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }

    }

    @IBAction func viewVideo(sender: AnyObject) {
        // Display Photo Library
        print("Play a video")

        
        let urlsForDocDirectory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
        let docPath:NSURL = urlsForDocDirectory[0] as NSURL
        let file = docPath.URLByAppendingPathComponent("video")
        var content : [String] = []
        do{try content = fileManager.contentsOfDirectoryAtPath(file.path!)}catch{}
       
        print("contentsOfPath: \(content)")
        
        print("got a video")
//        
//        // Find the video in the app's document directory
//        let paths = NSSearchPathForDirectoriesInDomains(
//            NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        let documentsDirectory: AnyObject = paths[0]
//        let dataPath = documentsDirectory.stringByAppendingPathComponent(saveFileName)
//        let videoAsset = (AVAsset(URL: NSURL(fileURLWithPath: dataPath)))
//        let playerItem = AVPlayerItem(asset: videoAsset)
//        
//        // Play the video
//        let player = AVPlayer(playerItem: playerItem)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        
//        self.presentViewController(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }

    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        
        // 1
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
    
        if mediaType is String{
            
            let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
            var videoName : String = ""
            let alertController = UIAlertController(title: "视频名称", message: "输入视频的文件名", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addTextFieldWithConfigurationHandler {
                (textField: UITextField!) -> Void in
                textField.placeholder = "文件名"
            }
            let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                let tmp = (alertController.textFields?.first)! as UITextField
                
                videoName = tmp.text!
                if videoName != ""{
                    videoName = videoName + ".mp4"
                    print("videoName is \(videoName)")
                    if !self.fileManager.fileExistsAtPath(self.videoDirPath) {
                        do{try self.fileManager.createDirectoryAtPath(self.videoDirPath,withIntermediateDirectories: true, attributes: nil)}catch{}
                    }
                    let videoData = NSData(contentsOfURL: urlOfVideo!)
                    videoData?.writeToFile(self.videoDirPath + videoName, atomically: false)
                }else{
                    print("videoName is empty")
                }
                self.dismissViewControllerAnimated(true, completion: {
                    // Anything you want to happen when the user selects cancel
                })
            }
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
                (action:UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(true, completion: {
                    // Anything you want to happen when the user selects cancel
                })
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            picker.presentViewController(alertController, animated: true, completion: nil)
            
                    
//                    if let url = urlOfVideo {
//                        // 2
//                        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(url,
//                            completionBlock: {(url: NSURL!, error: NSError!) in
//                                if let theError = error{
//                                    print("Error saving video = \(theError)")
//                                }
//                                else {
//                                    print("no errors happened")
//                                }
//                        })
//                    }
        
        }
        
    }
    func createFile(name:String,fileBaseUrl:NSURL){
        
    
        let file = fileBaseUrl.URLByAppendingPathComponent(name)
        print("文件: \(file)")
        let exist = fileManager.fileExistsAtPath(file.path!)
        if !exist {
            let data = NSData(base64EncodedString:"aGVsbG8gd29ybGQ=",options:.IgnoreUnknownCharacters)
            let createSuccess = fileManager.createFileAtPath(file.path!,contents:data,attributes:nil)
            print("文件创建结果: \(createSuccess)")
        }
    }
    @IBAction func EditFile(sender: AnyObject) {
        
        
        
        let urlForDocument = fileManager.URLsForDirectory( NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
        let url = urlForDocument[0] as NSURL
    
        createFile("test.txt", fileBaseUrl: url)
        
        let urlsForDocDirectory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
        let docPath:NSURL = urlsForDocDirectory[0] as NSURL
        let file = docPath.URLByAppendingPathComponent("test.txt")
        
       
        let data = fileManager.contentsAtPath(file.path!)
        let readString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print("文件内容: \(readString!)")
        let string = "添加一些文字到文件末尾"
        let appendedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        do{
            //let writeHandler = try NSFileHandle(forWritingToURL:file);
            let writeHandler = try NSFileHandle(forWritingToURL:file);
            writeHandler.seekToEndOfFile()
            writeHandler.writeData(appendedData!)
            writeHandler.closeFile()
        }catch{
            
        }
    
        //createFile("folder/new.txt", fileBaseUrl: url)
    }
    

        // Called when the user selects cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        self.dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    
    // Any tasks you want to perform after recording a video
    func videoWasSavedSuccessfully(video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
        print("Video saved")
        if let theError = error {
            print("An error happened while saving the video = \(theError)")
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // What you want to happen
            })
        }
    }
    
    
    // MARK: Utility methods for app
    // Utility method to display an alert to the user.
    func postAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

