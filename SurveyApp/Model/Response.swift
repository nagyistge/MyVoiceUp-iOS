//
//  Response.swift
//  SurveyApp
//
//  Created by Christian Kellner on 10/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation

class Response {
    
    struct Location {
        var latitude: Double
        var longitude: Double
    }
    
    var uuid: String
    var surveyIdentifier: String
    var timestamp: NSDate
    var location: Location?
    
    init(survey_id: String) {
        timestamp = NSDate()
        surveyIdentifier = survey_id
        uuid = NSUUID().UUIDString
    }
    
    var answers = [Answer]()
    
    func addAnswer(answer: Answer) {
        
        let possibleAnswer = find(answers, answer)
        
        if let a = possibleAnswer {
            println("[I] replacing existing answer")
            answers.removeAtIndex(a)
        }
        
        answers.append(answer)
    }
    
    func answerForQuestion(question: Question) -> Answer? {
        return answerForQuestion(question.identifier)
    }

    func answerForQuestion(question_id: String) -> Answer? {
        return answers.filter{ $0.question_id == question_id }.first
    }
}