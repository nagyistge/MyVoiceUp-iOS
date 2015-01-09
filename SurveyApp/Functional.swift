//
//  Functional.swift
//  SurveyApp
//
//  Created by Christian Kellner on 09/01/15.
//  Copyright (c) 2015 Christian Kellner. All rights reserved.
//

import Foundation

extension Optional {

    func flatMap<U>(closure: (obj: T) -> (Optional<U>)) -> Optional<U> {

        switch self {
        case .None:
            return Optional<U>.None;

        case .Some(let data):
            return closure(obj: data)
        }
    }
}

extension Array {
    func flatMap<U>( closure: (obj: T) -> (Optional<U>)) -> Array<U> {
        return self.map{ closure(obj: $0) }.filter{ $0 != nil }.map{ $0! }
    }
}