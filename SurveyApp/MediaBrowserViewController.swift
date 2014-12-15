//
//  MediaBrowserViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 10/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class MediaBrowserViewController: UITableViewController {
    
    var files: [MediaFile]?
    
    override func viewDidLoad() {
        files = DataStore.sharedInstance.listMediaFiles()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fm = NSFileManager.defaultManager()
        let mediaURL = DataStore.sharedInstance.mediaURL
        var err: NSError?
        let files = fm.contentsOfDirectoryAtURL(mediaURL, includingPropertiesForKeys: [NSURLNameKey, NSURLFileResourceTypeKey], options: nil, error: &err)
        
        return files?.count ?? 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MediaInfoCell") as UITableViewCell
        
        let curFile = files![indexPath.row].uuid
        cell.textLabel?.text = curFile
        cell.textLabel?.font = UIFont.systemFontOfSize(12)
        
        return cell
    }

    
    
}
