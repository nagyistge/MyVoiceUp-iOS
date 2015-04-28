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
        
        if let b = theTask as? QuestionBlock {
            cell.itemSymbol!.text = ""

            let ac = b.questions.filter({ self.response.answerForQuestion($0) != nil }).count
            print(ac)
            if ac == b.questions.count {
                cell.itemStatus!.text = ""
                cell.itemStatus!.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            } else {
                cell.itemStatus!.text = ""
                cell.itemStatus!.textColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            }

        } else if let b = theTask as? VoiceBlock {
            cell.itemSymbol!.text = ""

            if response.answerForQuestion(b.name) != nil {
                cell.itemStatus!.text = ""
                cell.itemStatus!.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            } else {
                cell.itemStatus!.text = ""
                cell.itemStatus!.textColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            }
        }
        
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
            let b = survey.groups.filter({$0.name == taskViewController.result.identifier}).first!
            let answers = b.answersForResult(taskViewController.result)
            for answer in answers {
                response.addAnswer(answer)
            }

            self.tableView.reloadData() //should be reloadRowAtIndexPath

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

