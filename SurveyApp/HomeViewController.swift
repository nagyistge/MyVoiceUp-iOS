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
    
    
    @IBOutlet weak var numResponsesLabel: UILabel!
    @IBOutlet weak var numStreakLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        if let index = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(index, animated: false)
        }
        
        self.numResponsesLabel.text = String(format:"%d responses", DataStore.sharedInstance.numberOfResponses)
    }

    func surveyViewController(viewController: SurveyViewController, finishedSurvey: Survey) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if let destVC = segue.destinationViewController as? SurveyViewController {
            destVC.delegate = self
        } else {
            self.navigationController?.navigationBarHidden = false
        }
    }
}

class ResponsesInfoCell: UITableViewCell {

}
