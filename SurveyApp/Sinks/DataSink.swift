//
//  DataSink.swift
//  SurveyApp
//
//  Created by Christian Kellner on 02/01/2015.
//  Copyright (c) 2015 Christian Kellner. All rights reserved.
//

import UIKit


protocol DataSinkDelegate {
    func dataSink(sink: DataSink, uploadStartedForResponse response: Response)
    func dataSink(sink: DataSink, uploadDoneForResponse response: Response)
    func dataSink(sink: DataSink, errorDuringTransfer error: NSError)
}

class DataSink {
    var delegate: DataSinkDelegate?
    var id: String
    
    init(id: String) {
        self.id = id
    }
    
    class func fromJSON(data: JSON) -> DataSink? {
        return nil;
    }
    
    func toJSON() -> NSDictionary {
        return NSDictionary()
    }
}


protocol SinkSetupDelegate {
    func sinkSetup(sinkSetup: SinkSetup, setupDoneWithResult result: Result<DataSink>)
}

class SinkSetup {

    class func fromJSON(data: JSON) -> Result<SinkSetup> {

        if let sinkType = data["type"].string {
            switch sinkType {
                case "DataHub":
                return DHSetup.fromJSON(data)
            default:
                let error = NSError(domain: "json", code: 1, userInfo: nil)
                return Result<SinkSetup>.Error(error)
            }
        } else {
            return Result<SinkSetup>.Error(NSError(domain: "json", code: 0, userInfo: nil))
        }
    }

    func createUI(parent: SinkSetupDelegate) -> UIViewController {
        fatalError("Implement me!")
    }
}
