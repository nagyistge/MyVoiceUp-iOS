//
//  DataSink.swift
//  SurveyApp
//
//  Created by Christian Kellner on 02/01/2015.
//  Copyright (c) 2015 Christian Kellner. All rights reserved.
//

import Foundation


protocol DataSinkDelegate {
    func dataSink(sink: DataSink, uploadStartedForResponse response: Response)
    func dataSink(sink: DataSink, uploadDoneForResponse response: Response)
    func dataSink(sink: DataSink, errorDuringTransfer error: NSError)
}

class DataSink {
    var delegate: DataSinkDelegate?
    
    init() {
        
    }
}
