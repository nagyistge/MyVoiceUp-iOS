//
//  Ohmage2Sink.swift
//  SurveyApp
//
//  Created by Christian Kellner on 14/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation

protocol DataSinkDelegate {
    func dataSink(sink: DataSink, uploadStartedForResponse response: Response)
    func dataSink(sink: DataSink, uploadDoneForResponse response: Response)
    func dataSink(sink: DataSink, errorDuringTransfer error: NSError)
}

class DataSink {
    var delegate: DataSinkDelegate?
    
    init() {
        
    }
}


class Ohmage2Sink: DataSink {
    
    var oc: Ohmage2Client
    var response: Response!
    
    override init() {
        let url = NSURL(string: "http://localhost:8080/app/")
        oc = Ohmage2Client(forURL: url)
        super.init()
    }
    
    func uploadResponse(response: Response) {
        self.response = response
        oc.authenticateForUser("testuser", withPassword: "testuser", onCompletion:authCallback)
        if let d = delegate {
            d.dataSink(self, uploadStartedForResponse: response)
        }
    }
    
    func authCallback(res: Bool, err: NSError?) {
        if (res) {
            self.oc.fetchCampaignForName(response.surveyIdentifier, onCompletion: fetchCampaignCallback)
        } else {
            if let d = delegate {
                d.dataSink(self, errorDuringTransfer: err!)
            }
        }
    }
    
    func fetchCampaignCallback(campaign: [NSObject: AnyObject]!, res: Bool, err: NSError?) {
        if (res) {
            let dataStore = DataStore.sharedInstance;
            let mediaFiles = dataStore.mediaFileForResponse(response)
            let media =  mediaFiles.map{ ["uuid": $0.uuid, "url": $0.url] }
            
            let campDict = campaign as [NSString: AnyObject]
            if let k = campDict.keys.first {
                
                let json = JSON(campaign)
                let urn: String = k
                
                var r: [String: AnyObject] = self.response2dict(response)
                var s: [String: AnyObject] = ["urn": urn,
                    "creation_timestamp": json[urn]["creation_timestamp"].stringValue]
            
                self.oc.uploadResponse(r, forSurvey: s, withMedia: media, onCompletion: uploadCallback)
                
            } else {
                let err = NSError(domain: "ohmage", code: 1, userInfo: nil)
                if let d = delegate {
                    d.dataSink(self, errorDuringTransfer: err)
                }
                return;
            }
            
        } else {
            if let d = delegate {
                d.dataSink(self, errorDuringTransfer: err!)
            }
        }

    }
    
    func uploadCallback(res: Bool, err: NSError?) {
        if let d = delegate {
            if (res) {
                d.dataSink(self, uploadDoneForResponse: response)
            } else {
                d.dataSink(self, errorDuringTransfer: err!)
            }
        }
    }
    
    private func response2dict(response: Response) -> [String: AnyObject] {
        
        let timestamp: NSNumber = (response.timestamp.timeIntervalSince1970 * 1000)
        
        var s: [String: AnyObject] = ["survey_key": response.uuid,
            "time": timestamp,
            "timezone": NSTimeZone.localTimeZone().abbreviation!,
            "location_status": "unavailable",
            "survey_id": response.surveyIdentifier,
            "survey_launch_context": [
                "launch_time": timestamp,
                "launch_timezone": NSTimeZone.localTimeZone().abbreviation!,
                "active_triggers": [NSString]()],
            "responses": response.answers.map{self.answer2dict($0)}]
        
        return s;
    }
    
    private func answer2dict(answer: Answer) -> [String: AnyObject] {
        var json: [String: AnyObject] =  ["prompt_id": answer.question_id]
        
        if let a = answer as? ValuedAnswer<String> {
            json["value"] = a.value
        } else if let a = answer as? ValuedAnswer<Bool> {
            json["value"] = a.value ? 1 : 0
        } else if let a = answer as? ValuedAnswer<Int> {
            json["value"] = a.value
        } else if let a = answer as? ValuedAnswer<Float> {
            json["value"] = a.value
        } else if let a = answer as? ValuedAnswer<MediaFile> {
            json["value"] = a.value.uuid.lowercaseString
        }
        
        return json
    }
    
}