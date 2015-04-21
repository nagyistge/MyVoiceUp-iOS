//
//  Question.swift
//  SurveyApp
//
//  Created by Christian Kellner on 05/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation
import SwiftyJSON
import ResearchKit

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
    
    //ResearchKit
    
    func asStep() -> ORKStep {
        fatalError("Implement me!")
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
    
    override func asStep() -> ORKStep {
        let txtChoices = choices.map{ ORKTextChoice(text: $0, value: $0) }
        
        let frmt = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: txtChoices)
        let step = ORKQuestionStep(identifier: self.identifier, title: self.identifier, answer: frmt)
        
        step.text = self.question_text
        step.optional = self.skippable
        
        return step
    }
}

class QBoolChoice: Question {
    var trueChoice = "Yes"
    var falseChoice = "No"
    
    override func asStep() -> ORKStep {
        let answerFormat = ORKBooleanAnswerFormat()
        let questionStep = ORKQuestionStep(identifier: self.identifier, title: self.identifier, answer: answerFormat)
        questionStep.text = self.question_text
        questionStep.optional = self.skippable
        return questionStep
    }
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
    
    override func asStep() -> ORKStep {
    
        let frmt = ORKAnswerFormat.continuousScaleAnswerFormatWithMaxValue(self.rangeMax.doubleValue, minValue: self.rangeMin.doubleValue, defaultValue: self.rangeMax.doubleValue, maximumFractionDigits: 2)
        let step = ORKQuestionStep(identifier: self.identifier, title: self.question_text, answer: frmt)
        
        step.text = self.question_text
        step.optional = self.skippable
        
        return step
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
    
    override func asStep() -> ORKStep {
        
        let imgChoices = choices.map{ ORKImageChoice(normalImage: UIImage(named: $0.image), selectedImage: nil, text: $0.text, value: $0.text!) }
        
        let frmt = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(imgChoices)
        let step = ORKQuestionStep(identifier: self.identifier, title: self.identifier, answer: frmt)
        
        step.text = self.question_text
        step.optional = self.skippable
        
        return step
    }
}
