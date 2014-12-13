//
//  Answer.swift
//  SurveyApp
//
//  Created by Christian Kellner on 10/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import Foundation

class Answer: Equatable {
    var question_id: String = ""
    
    init(qid: String) {
        question_id = qid
    }
}

func ==(lhs: Answer, rhs: Answer) -> Bool {
    return lhs.question_id == rhs.question_id
}

class ValuedAnswer<T>: Answer {
    
    var value: T
    init(qid: String, value: T) {
        self.value = value
        super.init(qid: qid)
    }
}

