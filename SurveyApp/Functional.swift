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

final class BoxedValue<T> {
    let val: T

    init(_ value: T) {
        val = value
    }
}

enum Result<T> {
    case Success(BoxedValue<T>)
    case Error(NSError)

    func map<U>(closure: (val: T) -> (U)) -> Result<U> {
        switch self {
        case .Success(let value):
            return Result<U>.Success(BoxedValue<U>(closure(val: value.val)))
        case .Error(let error):
            return Result<U>.Error(error)
        }
    }

    func flatMap<U>(closure: (val: T) -> (Result<U>)) -> Result<U> {
        switch self {
        case .Success(let value):
            return closure(val: value.val)
        case .Error(let error):
            return Result<U>.Error(error)
        }
    }

    static func make(value: T) -> Result<T> {
        return Result<T>.Success(BoxedValue<T>(value))
    }
}