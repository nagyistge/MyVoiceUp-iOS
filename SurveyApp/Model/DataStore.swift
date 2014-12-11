//
//  DataStore.swift
//  SurveyApp
//
//  Created by Christian Kellner on 07/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation

private let _singelton = DataStore()

class DataStore {
    class var sharedInstance: DataStore {
        return _singelton
    }
    
    var survey: Survey?
    var mediaURL: NSURL
    
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
        var err: NSError?
        fm.createDirectoryAtPath(mediaURL.path!, withIntermediateDirectories: true, attributes:nil, error: &err)
        //fixme: check error
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