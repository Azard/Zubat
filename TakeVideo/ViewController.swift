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
    let saveFileName = "/test.mp4"

    @IBAction func takeVideo(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                
                presentViewController(imagePicker, animated: true, completion: {})
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
        controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        controller.mediaTypes = [kUTTypeMovie as String]
        controller.delegate = self
        
//        presentViewController(controller, animated: true, completion: nil)
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
        
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                    if let url = urlOfVideo {
                        // 2
                        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(url,
                            completionBlock: {(url: NSURL!, error: NSError!) in
                                if let theError = error{
                                    print("Error saving video = \(theError)")
                                }
                                else {
                                    print("no errors happened")
                                }
                        })
                    }
                }
                
            }
        }
        
        // 3
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func createFile(name:String,fileBaseUrl:NSURL){
        let manager = NSFileManager.defaultManager()
    
        
        let file = fileBaseUrl.URLByAppendingPathComponent(name)
        print("文件: \(file)")
        let exist = manager.fileExistsAtPath(file.path!)
        if !exist {
            let data = NSData(base64EncodedString:"aGVsbG8gd29ybGQ=",options:.IgnoreUnknownCharacters)
            let createSuccess = manager.createFileAtPath(file.path!,contents:data,attributes:nil)
            print("文件创建结果: \(createSuccess)")
        }
    }
    @IBAction func EditFile(sender: AnyObject) {
        
        
        //在文档目录下新建test.txt文件
        let manager = NSFileManager.defaultManager()
        let urlForDocument = manager.URLsForDirectory( NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
        let url = urlForDocument[0] as NSURL
    
        createFile("test.txt", fileBaseUrl: url)
        
        let urlsForDocDirectory = manager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
        let docPath:NSURL = urlsForDocDirectory[0] as NSURL
        let file = docPath.URLByAppendingPathComponent("test.txt")
        
       
        let data = manager.contentsAtPath(file.path!)
        var readString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print("文件内容: \(readString)")
        let string = "添加一些文字到文件末尾"
        let appendedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        do{
            let writeHandler = try NSFileHandle(forWritingToURL:file);
            writeHandler.seekToEndOfFile()
            writeHandler.writeData(appendedData!)
        }catch{
            
        }
    
        //createFile("folder/new.txt", fileBaseUrl: url)
    }
    
//    func saveMovie(info: [NSObject : AnyObject],fileName:String){
//        let filePath       = SCPath.getDocumentPath().stringByAppendingString(fileName)
//        //获取系统保存的视频的URL
//        let mediaUrl:NSURL = info[UIImagePickerControllerMediaURL] as! NSURL
//        //转换为NSData
//        let mediaData      = NSData(contentsOfURL: mediaUrl)
//        mediaData!.writeToFile(filePath, atomically: true)
//    }
    
    // MARK: UIImagePickerControllerDelegate delegate methods
    // Finished recording a video
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        print("Got a video")
//        
//        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
//            // Save video to the main photo album
//            let selectorToCall = Selector("videoWasSavedSuccessfully:didFinishSavingWithError:context:")
//            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, selectorToCall, nil)
//            
//            // Save the video to the app directory so we can play it later
//            let videoData = NSData(contentsOfURL: pickedVideo)
//            let paths = NSSearchPathForDirectoriesInDomains(
//                NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//            let documentsDirectory: AnyObject = paths[0]
//            let dataPath = documentsDirectory.stringByAppendingPathComponent(saveFileName)
//            videoData?.writeToFile(dataPath, atomically: false)
//            
//        }
//        
//        imagePicker.dismissViewControllerAnimated(true, completion: {
//            // Anything you want to happen when the user saves an video
//        })
//    }
    
    // Called when the user selects cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
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

