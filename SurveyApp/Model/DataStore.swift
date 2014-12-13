//
//  DataStore.swift
//  SurveyApp
//
//  Created by Christian Kellner on 07/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation

private let _singelton = DataStore()

class MediaFile {
    var uuid: String
    var url: NSURL
    
    init(uuid: String, url: NSURL) {
        self.uuid = uuid
        self.url = url
    }
    
}

class DataStore {
    class var sharedInstance: DataStore {
        return _singelton
    }
    
    var survey: Survey?
    var mediaURL: NSURL
    var storeURL: NSURL
    
    init() {
        if let file = NSBundle(forClass:AppDelegate.self).pathForResource("Questions", ofType: "json") {
            let data = NSData(contentsOfFile: file)!
            let json = JSON(data: data)
            survey = Survey(json: json)
        } else {
            survey = nil
        }
        
        let fm = NSFileManager.defaultManager()
        let docUrls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        mediaURL = docUrls[0].URLByAppendingPathComponent("media")
        storeURL = docUrls[0] as NSURL
        var err: NSError?
        fm.createDirectoryAtURL(mediaURL, withIntermediateDirectories: true, attributes:nil, error: &err)
        //fixme: check error
        
        let responseDataURL = docUrls[0].URLByAppendingPathComponent("responses/data/", isDirectory: true)
        fm.createDirectoryAtURL(responseDataURL, withIntermediateDirectories: true, attributes: nil, error: &err)
        
        let responsesDateIndex = docUrls[0].URLByAppendingPathComponent("responses/by_date/", isDirectory: true)
        fm.createDirectoryAtURL(responsesDateIndex, withIntermediateDirectories: true, attributes: nil, error: &err)
    
    }
    
    func generateMediaURL(uuid: String, suffix: String) -> NSURL {
        let fm = NSFileManager.defaultManager()
        let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let filename = String(format: "media/%@.%@", uuid, suffix)
        let fullURL = urls[0].URLByAppendingPathComponent(filename)
        println("Generated Media URL: \(fullURL, urls[0], uuid, filename)")
        return fullURL
    }
    
}