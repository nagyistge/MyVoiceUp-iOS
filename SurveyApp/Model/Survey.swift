//
//  Survey.swift
//  SurveyApp
//
//  Created by Christian Kellner on 05/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation

class Survey {
    
    var uuid: String
    var identifier: String
    var date: NSDate
    var author: String?
    var questions = [Question]()
    
    init(json: JSON) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        questions = json["questions"].arrayValue.map { Question.fromJSON($0) }.filter { $0 != nil }.map { $0! }
        date = formatter.dateFromString(json["date"].stringValue)!
        identifier = json["id"].stringValue
        author = json["author"].string

        if let theId = json["uuid"].string {
            uuid = theId
        } else {
            uuid = NSUUID().UUIDString
        }
    }

    init(uuid: String, id: String, date: NSDate, questions: [Question] = [Question]()) {
        self.uuid = uuid
        self.identifier = id
        self.date = date
        self.questions = questions
    }
    
}