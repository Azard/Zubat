//
//  IndexViewController.swift
//  SwiftRadio
//
//  Created by guoyanchang on 16/3/16.
//  Copyright © 2016年 CodeMarket.io. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

class IndexViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    let videoPicker: UIImagePickerController! = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func takeVideo(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                
                videoPicker.sourceType = .Camera
                videoPicker.mediaTypes = [kUTTypeMovie as String]
                videoPicker.allowsEditing = false
                videoPicker.videoQuality = .TypeHigh
                videoPicker.delegate = self
                //self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                self.presentViewController(videoPicker, animated: true, completion: {print("camera completed")})
            } else {
                postAlert("Rear camera doesn't exist", message: "Application cannot access the camera.")
            }
        } else {
            postAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
        
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
                    print("videoName is \(videoName)")
                    let videoData = NSData(contentsOfURL: urlOfVideo!)
                    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                    myActivityIndicator.center = picker.view.center
                    myActivityIndicator.startAnimating()
                    picker.view.addSubview(myActivityIndicator)
                    Video.storeVideo(videoName, videoData: videoData!)
                    myActivityIndicator.stopAnimating()
                    
                    
                }else{
                    print("videoName is empty")
                }
                self.dismissViewControllerAnimated(true, completion:nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
                (action:UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            picker.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func editVideo(sender: AnyObject) {
        Video.listAllVideo()
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let svc = segue.destinationViewController as? StationsViewController{
//            if let idf = segue.identifier{
//                if idf == "VIewVideo"{
//                    print("VIewVideo")
//                }
//            }
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func postAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}