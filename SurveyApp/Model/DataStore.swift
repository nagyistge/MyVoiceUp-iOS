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
    
    var numberOfResponses: Int {
        
        get {
            let dataURL = storeURL.URLByAppendingPathComponent("responses/data/", isDirectory: true)
            let fm = NSFileManager.defaultManager()
            let contents = fm.contentsOfDirectoryAtURL(dataURL, includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants, error: nil)
            return contents?.count ?? 0
        }
    }
    
    var currentStreak: Int {
        get {
            return 0;
        }
    }
    
    var datesWithResponses: [NSDate] {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "C")
        dateFormatter.dateFormat = "yyyy-MM-dd"
    
        let fm = NSFileManager.defaultManager()
        let dateURL = storeURL.URLByAppendingPathComponent("responses/by_date", isDirectory: true)
        let allResponses = fm.contentsOfDirectoryAtURL(dateURL, includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants, error: nil)
        
        let dates = allResponses?.map{$0 as NSURL}.map{dateFormatter.dateFromString($0.lastPathComponent!)}.filter{$0 != nil}.map{$0!}.sorted{ $0.0.compare($0.1) == NSComparisonResult.OrderedDescending }
        return dates ?? [NSDate]()
        
    }
    
    func generateMediaURL(uuid: String, suffix: String) -> NSURL {
        let fm = NSFileManager.defaultManager()
        let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let filename = String(format: "media/%@.%@", uuid, suffix)
        let fullURL = urls[0].URLByAppendingPathComponent(filename)
        println("Generated Media URL: \(fullURL, urls[0], uuid, filename)")
        return fullURL
    }
    
    func storeReponse(response: Response) {
        
        let data = response2JSON(response)
        if let d = data {
            println(NSString(data: d, encoding: NSUTF8StringEncoding))
            
            let fm = NSFileManager.defaultManager()
            let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let dirpath = String(format: "responses/data/%@/", response.uuid)
            let dirURL = urls[0].URLByAppendingPathComponent(dirpath, isDirectory: true)
            
            var err: NSError?
            fm.createDirectoryAtURL(dirURL, withIntermediateDirectories: true, attributes:nil, error: &err)
            
            var filepath = String(format: "/%@.json", response.uuid)
            let fileURL = dirURL.URLByAppendingPathComponent(filepath, isDirectory: false)
            var result = d.writeToURL(fileURL, atomically: true)
            //fixme: check results
            
            //create the index entries
            //fm.createSymbolicLinkAtURL(, withDestinationURL: dirURL, error: &err)
        } else {
            println("[W] Oh oh")
        }
    }
 
    func response2JSON(response: Response) -> NSData? {
        var json: [String: AnyObject] = ["uuid": response.uuid,
                                         "sid": response.surveyIdentifier]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "C")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        json["timestap"] = dateFormatter.stringFromDate(response.timestamp)
        
        if let l = response.location {
            json["location"] = ["lat": l.latitude, "long": l.longitude ]
        }
        
        let answers = map(response.answers, { answer in self.answer2JSON(answer) })
        json["answers"] = answers
        var err: NSError?
        let data = NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted, error: &err)
        return data
    }
    
    private func answer2JSON(answer: Answer) -> NSDictionary {
        var json: [String: AnyObject] =  ["qid": answer.question_id]
        if let a = answer as? ValuedAnswer<String> {
            json["type"] = "string"
            json["value"] = a.value
        } else if let a = answer as? ValuedAnswer<Bool> {
            json["type"] = "bool"
            json["value"] = a.value
        } else if let a = answer as? ValuedAnswer<Int> {
            json["type"] = "int"
            json["value"] = a.value
        } else if let a = answer as? ValuedAnswer<Float> {
            json["type"] = "float"
            json["value"] = a.value
        } else if let a = answer as? ValuedAnswer<MediaFile> {
            json["type"] = "media-file"
            json["uuid"] = a.value.uuid
            json["filename"] = a.value.url.lastPathComponent!
        }
        return json
    }
}