//
//  Survey.swift
//  SurveyApp
//
//  Created by Christian Kellner on 05/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation
import SwiftyJSON
import ResearchKit


enum BlockType : Int {
    case Questions = 0
    case Audio = 1
}

class SurveyBlock {
    var name: String
    var type: BlockType
    
    init(name: String, type: BlockType, questions: [Question]) {
        self.name = name
        self.type = type
        self.questions = questions
    }
    
    var questions = [Question]()
    
    func asRKTask() -> ORKTask {
        switch(type) {
        case .Audio:
            return ORKOrderedTask.audioTaskWithIdentifier(name, intendedUseDescription: questions[0].question_text, speechInstruction: questions[0].question_text, shortSpeechInstruction: questions[0].question_text, duration: 20, recordingSettings: nil, options: nil)
            
        case .Questions:
            return ORKOrderedTask(identifier: name, steps: questions.map{ $0.asStep() })
            
        }
    }
}

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
    
    var groups : [SurveyBlock] {
        get {
            let audioQs = questions.filter{ $0 is QAudioRecording }.map{ $0 as! QAudioRecording }
            let surveyQs = questions.filter{ !($0 is QAudioRecording) }
            
            var grps = audioQs.map{ SurveyBlock(name: $0.identifier, type: .Audio, questions: [$0]) }
            grps += [SurveyBlock(name: "Questions", type: .Questions, questions: surveyQs)]
         
            return grps
        }
    }
    
}