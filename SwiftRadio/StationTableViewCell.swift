//
//  StationTableViewCell.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 4/4/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationTimeLabel: UILabel!
    @IBOutlet weak var stationImageView: UIImageView!
    
    //var downloadTask: NSURLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 78/255, green: 82/255, blue: 93/255, alpha: 0.6)
        selectedBackgroundView  = selectedView
    }

    func configureStationCell(video: Video) {
        
        // Configure the cell...
        stationNameLabel.text = video.videoName
        stationTimeLabel.text = video.videoDateToString
        stationImageView.image = video.previewImage
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stationNameLabel.text  = nil
        stationTimeLabel.text  = nil
        stationImageView.image = nil
    }
}