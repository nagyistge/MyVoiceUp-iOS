//
//  Campaign.swift
//  SurveyApp
//
//  Created by Christian Kellner on 23/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation


class Campaign {

    var indentifier: String
    var author: String?
    var info: String?

    var questions = [Question]()
    var templates = [SurveyTemplate]()
    
    init(id: String) {
        self.indentifier = id
    }
 
    struct SurveyTemplate {
        var date: NSDate
        var ttl: NSInteger
        var questions: [NSString]
    }

    func templatesForDate(date: NSDate) -> [SurveyTemplate] {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let inDays = gregorian.ordinalityOfUnit(.DayCalendarUnit, inUnit: .EraCalendarUnit, forDate: date)
        
        return self.templates.filter { template in
            let tempDays = gregorian.ordinalityOfUnit(.DayCalendarUnit, inUnit: .EraCalendarUnit, forDate: template.date)
            let deltaT = inDays - tempDays
            return deltaT >= 0 && deltaT < template.ttl
        }
    }
    
}