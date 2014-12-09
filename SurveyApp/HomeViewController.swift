//
//  HomeViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 08/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class HomeViewController : UIViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}


class HomeTableViewController: UITableViewController, UITableViewDataSource, SurveyViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    func surveyViewController(viewController: SurveyViewController, finishedSurvey: Survey) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if let destVC = segue.destinationViewController as? SurveyViewController {
            destVC.delegate = self
        }
    }
}