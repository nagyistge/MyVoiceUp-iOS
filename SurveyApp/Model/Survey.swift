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


class SurveyBlock {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func asRKTask() -> ORKTask {
        fatalError("abstract base method")
    }

    func answersForResult(result: ORKTaskResult) -> [Answer] {
        fatalError("abstract base method")
    }
}

class QuestionBlock : SurveyBlock {
    
    var questions = [Question]()
    
    init(name: String, questions: [Question]) {
        super.init(name: name)
        self.questions = questions
    }
    
    
    override func asRKTask() -> ORKTask {
        return ORKOrderedTask(identifier: name, steps: questions.map{ $0.asStep() })
    }

    override func answersForResult(result: ORKTaskResult) -> [Answer] {

        var answers = [Answer]()

        //ugly, ugly, please fix me
        for q in questions {
            let r = result.resultForIdentifier(q.identifier)
            assert(r != nil, "No answer for question found. Must not happen")
            let cr = r as! ORKStepResult
            let qr = cr.firstResult as? ORKQuestionResult
            assert(qr != nil, "Invalid result type found")
            if let sq = qr as? ORKBooleanQuestionResult {
                answers.append(ValuedAnswer<Bool>(qid: q.identifier, value: sq.booleanAnswer!.boolValue))
            } else if let sq = qr as? ORKScaleQuestionResult {
                answers.append(ValuedAnswer<NSNumber>(qid: q.identifier, value: sq.scaleAnswer!))
            } else if let sq = qr as? ORKChoiceQuestionResult {
                answers.append(ValuedAnswer<String>(qid: q.identifier, value: sq.choiceAnswers![0] as! String))
            }
        }
        return answers
    }
}

class VoiceBlock : SurveyBlock {
    
    var question_text: String

    init(name: String, qtext: String) {
        self.question_text = qtext
        super.init(name: name)
    }
    
    override func asRKTask() -> ORKTask {
        return ORKOrderedTask.audioTaskWithIdentifier(name, intendedUseDescription: question_text, speechInstruction: question_text, shortSpeechInstruction: question_text, duration: 20, recordingSettings: nil, options: nil)
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
            
            var grps = audioQs.map{ VoiceBlock(name: $0.identifier, qtext: $0.question_text) as SurveyBlock }
            grps += [QuestionBlock(name: "Questions", questions: surveyQs) as SurveyBlock ]
         
            return grps
        }
    }
    
}