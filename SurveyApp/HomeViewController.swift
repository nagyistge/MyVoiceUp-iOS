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
    @IBOutlet weak var surveyLabel: UILabel!

    var campaign: Campaign!
    var store: DataStore!
    var survey: Survey?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false

        store = DataStore.sharedInstance
        campaign = store.loadCampaign()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        if let index = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(index, animated: false)
        }

        self.numResponsesLabel.text = String(format:"%d responses", store.numberOfResponses)
        self.numStreakLabel.text = String(format: "%d days", store.currentStreak)

        let today = NSDate()
        survey = nil
        if store.haveResponseForDate(today) {
            println("Have response")
            surveyLabel.text = "Today's survey already done! :)"
        } else {
            survey = campaign.surveysForDate(today).first

            if let s = survey {
                println("Have survey!")
                surveyLabel.text = "Take today's survey"
            } else {
                surveyLabel.text = "No survey for today"
                println("No survey for today!")
            }
        }
    }

    func surveyViewController(viewController: SurveyViewController, forSurvey survey:Survey, withResponse response: Response) {

        store.storeReponse(response)
        
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
            destVC.survey = self.survey!
        } else {
            self.navigationController?.navigationBarHidden = false
        }
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "TakeSurvey" {
            if survey != nil {
                self.performSegueWithIdentifier("TakeSurveySegue", sender: cell)
            } else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
}

class ResponsesInfoCell: UITableViewCell {

}
