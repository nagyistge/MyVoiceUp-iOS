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
    
    // temp, will be removed
    var tasks = [ORKTask]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        response = Response(survey_id: survey.identifier)
        tasks = tasksForSurvey(survey)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SurveyItemCell", forIndexPath: indexPath) as! SurveyTaskCell
        
        let theTask = tasks[indexPath.row]
        cell.itemTitle!.text = "\(theTask.identifier)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let theTask = tasks[row]
        let tvc = ORKTaskViewController(task: theTask, taskRunUUID: nil)
        tvc.delegate = self
        presentViewController(tvc, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65;
    }

    //move this somewhere else, maybe the survey itself, or an survey extensions?
    
    func tasksForSurvey(su: Survey) -> [ORKTask] {
        let audioQs = su.questions.filter{ $0 is QAudioRecording }.map{ $0 as! QAudioRecording }
        let surveyQs = su.questions.filter{ !($0 is QAudioRecording) }
        
        var tasks = [ORKTask]()
        
        tasks += audioQs.map{ ORKOrderedTask.audioTaskWithIdentifier($0.identifier , intendedUseDescription: $0.question_text, speechInstruction: $0.question_text, shortSpeechInstruction: $0.question_text, duration: 20, recordingSettings: nil, options: nil) }.map{ $0 as ORKTask }
        
        let surveySteps = surveyQs.map{ $0.asStep() }
        print(surveySteps)
        tasks += [ORKOrderedTask(identifier: "Survey", steps: surveySteps) as ORKTask]
        print(tasks)
        return tasks
    }

    // ResearchKit's TVC
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
 
        //TODO: handle results
        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

class SurveyTaskCell : UITableViewCell {
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemDetail: UILabel!
    @IBOutlet weak var itemSymbol: UILabel!
    @IBOutlet weak var itemStatus: UILabel!
    
}

