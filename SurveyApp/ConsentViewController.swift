//
//  ConsentViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 19/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

protocol ConsentViewControllerDelegate {
    func didGiveConsent(vc:ConsentViewController);
}

class ConsentViewController: UIViewController {
    
    @IBOutlet weak var consentView: UIWebView!
    
    @IBAction func consentTouchUp(sender: AnyObject) {
        if let d = delegate {
            d.didGiveConsent(self)
        }
    }
    
    override func viewDidLoad() {
        if let file = NSBundle(forClass:AppDelegate.self).URLForResource("consent", withExtension: "html") {
            
            let data = NSData(contentsOfURL: file)
            if let d = data {
                let html = NSString(data: d, encoding: NSUTF8StringEncoding)
                self.consentView.loadHTMLString(html, baseURL: file.baseURL)
            }
        }
    }
    
    var delegate: ConsentViewControllerDelegate?
    
}
