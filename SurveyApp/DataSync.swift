//
//  UploadViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 15/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit
import SwiftyJSON

private let _ds_singelton = DataSync()

class DataSync {
    class var sharedInstance: DataSync {
        return _ds_singelton
    }
    
    var sinkBaseURL: NSURL!
    
    init() {
        let fm = NSFileManager.defaultManager()
        let docUrls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        sinkBaseURL = docUrls[0].URLByAppendingPathComponent("sinks")
        
        fm.createDirectoryAtURL(sinkBaseURL, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    func sinksForCampaign(campaign: Campaign) -> [DataSink] {
        let fm = NSFileManager.defaultManager()
        let campaignURL = self.urlForCampaign(campaign)
        
        let files = fm.contentsOfDirectoryAtURL(campaignURL, includingPropertiesForKeys: [NSURLNameKey, NSURLFileResourceTypeKey], options: nil, error: nil)
        
        let sinks = files?.map{ $0 as NSURL }.flatMap{ NSData(contentsOfURL: $0) }.map{ JSON(data: $0) }.flatMap{ DataSink.fromJSON($0) }
        return sinks ?? [DataSink]()
    }
    
    func register(sink: DataSink, campaign: Campaign) {
        let fm = NSFileManager.defaultManager()
        
        var err: NSError?
        
        let campaignURL = self.urlForCampaign(campaign)
        fm.createDirectoryAtURL(campaignURL, withIntermediateDirectories: true, attributes: nil, error: nil)
        
        let sinkURL = campaignURL.URLByAppendingPathComponent("\(sink.id).sink.json", isDirectory: false)
        
        let js = sink.toJSON()
        let data = NSJSONSerialization.dataWithJSONObject(js, options: .PrettyPrinted, error: &err)
        
        data?.writeToURL(sinkURL, atomically: true)
        //fixme: error handling, heh
        
    }
    
    func urlForCampaign(campaign: Campaign) -> NSURL {
        let sinkURL = sinkBaseURL.URLByAppendingPathComponent("\(campaign.indentifier)", isDirectory: true)
        return sinkURL
    }
    
}