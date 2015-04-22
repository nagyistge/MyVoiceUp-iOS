//
//  RootViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 03/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit
import ResearchKit

protocol SurveyViewControllerDelegate {
    func surveyViewController(viewController: SurveyViewController, forSurvey survey: Survey, withResponse response: Response)
}

class SurveyViewController: UITableViewController, ORKTaskViewControllerDelegate {

    var survey: Survey!
    var response: Response!
    
    var delegate: SurveyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        response = Response(survey_id: survey.identifier)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return survey.groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SurveyItemCell", forIndexPath: indexPath) as! SurveyTaskCell
        
        let theTask = survey.groups[indexPath.row]
        cell.itemTitle!.text = "\(theTask.name)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let theTask = survey.groups[row].asRKTask()
        let tvc = ORKTaskViewController(task: theTask, taskRunUUID: nil)
        tvc.delegate = self
        tvc.outputDirectory = DataStore.sharedInstance.mediaURL
        presentViewController(tvc, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65;
    }

    // ResearchKit's TVC
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
 
        //TODO: handle results
        switch (reason) {
        case .Completed:
            break;
            
        case .Failed:
            print("Survey Task Failed: \( error )");
            
        default:
            print("Implement me")
        }
        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

class SurveyTaskCell : UITableViewCell {
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemDetail: UILabel!
    @IBOutlet weak var itemSymbol: UILabel!
    @IBOutlet weak var itemStatus: UILabel!
    
}

