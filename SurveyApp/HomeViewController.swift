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
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        if let index = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(index, animated: false)
        }
        
        let ds = DataStore.sharedInstance
        self.numResponsesLabel.text = String(format:"%d responses", ds.numberOfResponses)
        self.numStreakLabel.text = String(format: "%d days", ds.currentStreak)
    }

    func surveyViewController(viewController: SurveyViewController, forSurvey survey:Survey, withResponse response: Response) {

        DataStore.sharedInstance.storeReponse(response)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("DataUpload") as DataUploadViewController
        vc.response = response
        self.navigationController?.navigationBar.topItem?.title = "Home"
        self.navigationController?.setViewControllers([self.parentViewController!, vc], animated: true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        super.prepareForSegue(segue, sender: sender)
        
        if let destVC = segue.destinationViewController as? SurveyViewController {
            self.navigationController?.navigationBarHidden = true
            destVC.delegate = self
        } else {
            self.navigationController?.navigationBarHidden = false
        }
    }
}

class ResponsesInfoCell: UITableViewCell {

}
