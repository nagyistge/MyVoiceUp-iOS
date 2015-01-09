//
//  DataHubSink.swift
//  SurveyApp
//
//  Created by Christian Kellner on 09/01/15.
//  Copyright (c) 2015 Christian Kellner. All rights reserved.
//

import Foundation

class DHSink : DataSink {

    var url: NSURL

    init(url: NSURL) {
        self.url = url
        super.init(id: self.url.absoluteString!.sha1())
    }

}