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
        gregorian.timeZone = NSTimeZone(name: "UTC")!
        let dateInDays = gregorian.ordinalityOfUnit(.DayCalendarUnit, inUnit: .EraCalendarUnit, forDate: date)

        return self.templates.filter { template in
            let tempDays = gregorian.ordinalityOfUnit(.DayCalendarUnit, inUnit: .EraCalendarUnit, forDate: template.date)
            let deltaT = dateInDays - tempDays
            return deltaT >= 0 && deltaT < template.ttl
        }.sorted { (a, b) in a.ttl > b.ttl }
    }
    
    func surveyForTemplate(template: SurveyTemplate) -> Survey? {
        
        let Q = self.questions.map{ $0.identifier }
        let uuid = NSUUID().UUIDString
        
        let qs = template.questions.map{ find(Q, $0) }.filter{ $0 != nil }.map{ self.questions[$0!] }
        
        if qs.count == template.questions.count {
            //fixme: the id is probably not right here
            return Survey(uuid: uuid, id: self.indentifier, date: template.date, questions: qs)
        } else {
            return nil
        }
    }
    
}