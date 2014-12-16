//
//  DataUploadViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 16/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class DataUploadViewController : UIViewController, DataSinkDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var uploadProgress: UIProgressView!
    @IBOutlet weak var uploadInidcator: UIActivityIndicatorView!
    
    var response: Response!
    
    var sink: Ohmage2Sink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        sink = Ohmage2Sink()
        
        sink.delegate = self
        self.statusLabel.text = "Starting upload"
        self.uploadProgress.progress = 0.0
        self.uploadInidcator.hidesWhenStopped = true
        sink.uploadResponse(response);
    }
    
    func dataSink(sink: DataSink, errorDuringTransfer error: NSError) {
        self.uploadInidcator.stopAnimating()
        self.statusLabel.text = String(format:"Error: %@", error.description)
    }
    
    func dataSink(sink: DataSink, uploadDoneForResponse response: Response) {
        self.uploadInidcator.stopAnimating()
        self.statusLabel.text = "Upload done!"
        self.uploadProgress.progress = 1.0
        self.navigationController?.navigationBarHidden = false
    }
    
    func dataSink(sink: DataSink, uploadStartedForResponse response: Response) {
        self.statusLabel.text = "Upload started"
        self.uploadProgress.progress = 0.0
        self.uploadInidcator.startAnimating()
//        self.uploadInidcator.hidden = fa

    }
}
