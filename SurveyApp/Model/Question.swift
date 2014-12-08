//
//  Question.swift
//  SurveyApp
//
//  Created by Christian Kellner on 05/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation
import SwiftyJSON

enum QuestionType : String {
    case Boolean = "boolean"
    case TextChoices = "text_choices"
    case ImageChoices = "image_choces"
    case AudioRecording = "audio_recording"
    case Range = "range"
}

class Question: Equatable {
    var question_text: String
    
    init(json: JSON) {
        question_text = json["question_text"].stringValue
    }
    
    class func fromJSON(json: JSON) -> Question? {
        //fixme: validate quesion?
        if let qtype = QuestionType(rawValue: json["question_type"].stringValue) {
            switch qtype {
            case .TextChoices:
                println("TextChoices")
                return QTextChoice(json: json)
            default:
                println("FIXME: not handled yet")
            }
        }
        
        return nil
    }
}

func ==(lhs: Question, rhs: Question) -> Bool {
    return lhs.question_text == rhs.question_text
}

class QTextChoice : Question {
    var choices = [String]()
    
    override init(json: JSON) {
        super.init(json: json)
        choices = json["choices"].arrayValue.map{$0.stringValue}
    }
}


