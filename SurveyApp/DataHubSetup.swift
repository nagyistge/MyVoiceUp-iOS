//
//  DataHubSetup.swift
//  SurveyApp
//
//  Created by Christian Kellner on 20/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

protocol DHSetupDelegate {
    
    func dataHubSetupComplete()
    func dataHubSetupFailed(error: NSError)
    
    func dataHubSetupProgress(currentAction: String, completedSetps: Int, totalSteps: Int)
}

class DHSetup : SinkSetup {
    
    enum State : NSInteger {
        case Error = -1
        case Init = 0
        case Register
        case CreateRepo
        case CreateTable
    }
    
    var client: DHClient
    var state = State.Init
    var delegate: DHSetupDelegate?

    override class func fromJSON(data: JSON) -> Result<SinkSetup> {

        let endpoint = data["url"].url
        let repo = data["repo"].string
        let sharedUser = data["shareWith"].string

        switch (endpoint, repo, sharedUser) {
        case (.Some(let u), .Some(let r), .Some(let s)):
            let dhss = DHSetup(url: u)
            return Result<SinkSetup>.make(dhss)

        default:
            return Result<SinkSetup>.Error(NSError(domain: "json", code: 1, userInfo: nil))
        }
    }

    init(url: NSURL) {
        client = DHClient(URL: url)
    }
    
    func onSuccess() {
        switch state {
        case .Register:
            println("Registering done")
            state = .CreateRepo
            client.createRepo("MyVoiceUp", andShareWith: "gicmo", onSuccess: onSuccess, onFailure: onError)
            reportProgress("Creating Repository", step: 1)

            
        case .CreateRepo:
            print("Creating repo done")
            state = .CreateTable
            client.createTable("responses", inRepo: "MyVoiceUp", withSchema: "id UUID PRIMARY KEY, data json", onSuccess: onSuccess, onFailure: onError)
            reportProgress("Creating Tables", step: 2)

        case .CreateTable:
            println("We are all set!")
            reportProgress("ALl done", step: 3)
            if let d = delegate {
                d.dataHubSetupComplete()
            }
            
        default:
            println("That should really never happen")
            let err = NSError(domain: "DataHubSetup", code: 42, userInfo: nil)
            onError(err)
        }
    }
    
    func onError(err: NSError!) {
        state = .Error
        if let d = delegate {
            d.dataHubSetupFailed(err)
        }
    }
    
    func register(user: String, email: String, password: String) {
        state = .Register
        client.registerUser(user, withEmail: email, andPassword: password, onSuccess: onSuccess, onFailure: onError)
        reportProgress("Register user", step: 0)
        
    }
    
    //private helpers
    
    private func reportProgress(progress: String, step: Int) {
        if let d = delegate {
            d.dataHubSetupProgress(progress, completedSetps: step, totalSteps: 3)
        }
    }
}

class DHRegisterViewController: UITableViewController, UITextFieldDelegate, DHSetupDelegate {
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    var dhSetup: DHSetup?
    var hudBackground: UIView?
    
    override func viewDidLoad() {
        userInput.delegate = self
        emailInput.delegate = self
        passwordInput.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1;
        println("next tag \(nextTag)")
        
        let nextResponer = self.tableView.viewWithTag(nextTag)
        
        if let responder = nextResponer {
            responder.becomeFirstResponder()
        } else {
            // this means we should actually register
            textField.resignFirstResponder()
            startRegister()
        }
        
        return false
    }
    
    func startRegister() {
        
        self.hudBackground = UIView(frame: self.view.bounds)
        self.hudBackground?.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.hudBackground?.clipsToBounds = true

        self.view.addSubview(self.hudBackground!)
        
        SVProgressHUD.showProgress(0, status: "Waiting for client")
        self.dhSetup = DHSetup(url: NSURL(string: "http://localhost:8000")!)

        let user = self.userInput.text
        let pass = self.passwordInput.text
        let email = self.emailInput.text
        
        self.dhSetup?.delegate = self
        self.dhSetup?.register(user, email: email, password: pass)
        
    }
    
    func dataHubSetupComplete() {
        SVProgressHUD.showSuccessWithStatus("All done!")
        SVProgressHUD.dismiss()
    }
    
    func dataHubSetupFailed(error: NSError) {
        SVProgressHUD.showErrorWithStatus(error.description)
        if let hv = self.hudBackground {

            UIView.animateWithDuration(5.0, animations: { () -> Void in
                hv.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }, completion: { completed in
                hv.removeFromSuperview()
            })
        }
    }
    
    func dataHubSetupProgress(currentAction: String, completedSetps: Int, totalSteps: Int) {
        SVProgressHUD.showProgress(Float(completedSetps)/Float(completedSetps), status: "Waiting for client")
    }
}