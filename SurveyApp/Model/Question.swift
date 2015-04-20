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
    case ImageChoices = "image_choices"
    case AudioRecording = "audio_recording"
    case Range = "range"
}

class Question: Equatable {
    var identifier: String
    var question_text: String
    var skippable = false
    
    init(json: JSON) {
        identifier = json["question_id"].stringValue
        question_text = json["question_text"].stringValue
        
        if let canSkip = json["skippable"].bool {
            skippable = canSkip
        }
    }
    
    class func fromJSON(json: JSON) -> Question? {
        //fixme: validate quesion?
        if let qtype = QuestionType(rawValue: json["question_type"].stringValue) {
            switch qtype {
            case .Boolean:
                println("Boolean")
                return QBoolChoice(json: json)
            case .TextChoices:
                println("TextChoices")
                return QTextChoice(json: json)
            case .AudioRecording:
                println("AudioRecording")
                return QAudioRecording(json: json)
            case .Range:
                println("Range")
                return QRange(json: json)
            case .ImageChoices:
                println("ImageChoices")
                return QImgChoice(json: json)
            default:
                println("FIXME: not handled yet")
            }
        }
        
        return nil
    }
}

func ==(lhs: Question, rhs: Question) -> Bool {
    return lhs.identifier == rhs.identifier
}

class QTextChoice : Question {
    var choices = [String]()
    
    override init(json: JSON) {
        super.init(json: json)
        choices = json["choices"].arrayValue.map{$0.stringValue}
    }
}

class QBoolChoice: Question {
    var trueChoice = "Yes"
    var falseChoice = "No"
    
}

class QAudioRecording: Question {
    
}

class QRange: Question {
    var rangeMin: NSNumber = 0
    var rangeMax: NSNumber = 1
    var rangeStep: NSNumber = 0.1
    
    override init(json: JSON) {
        super.init(json: json)
        
        if let v = json["range_min"].number {
            rangeMin = v
        }
        
        if let v = json["range_max"].number {
            rangeMax = v
        }
        
        if let v = json["range_step"].number {
            rangeStep = v
        }
    }
}

class QImgChoice: Question {
    struct Choice {
        var image: String
        var text: String?
    }

    var choices = [Choice]()
    
    override init(json: JSON) {
        super.init(json: json)
        
        choices = json["choices"].arrayValue.map{Choice(image: $0["image"].stringValue, text: $0["label"].string)}
        
    }
}
