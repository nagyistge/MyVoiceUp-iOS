//
//  Survey.swift
//  SurveyApp
//
//  Created by Christian Kellner on 05/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation
import SwiftyJSON

class Survey {
    
    var date: NSDate
    var questions = [Question]()
    
    init(json: JSON) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        questions = json["questions"].arrayValue.map { Question.fromJSON($0) }.filter { $0 != nil }.map { $0! }
        date = formatter.dateFromString(json["date"].stringValue)!
    }
    
}