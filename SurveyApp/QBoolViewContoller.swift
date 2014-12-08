//
//  QBoolViewContoller.swift
//  SurveyApp
//
//  Created by Christian Kellner on 08/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class QBoolViewController: QuestionViewController {
    
    weak var txtChoiceQ: QBoolChoice!
    weak var answerViewController: QBoolAnswerViewController!
    
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtChoiceQ = super.question as QBoolChoice
        println("view did load finished")
        answerViewController.trueLabel.text = txtChoiceQ.trueChoice
        answerViewController.falseLabel.text = txtChoiceQ.falseChoice
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "embedYesNo" {
                answerViewController = segue.destinationViewController as QBoolAnswerViewController
                println("Have view controller")
            }
        }
    }
    
}

class QBoolAnswerViewController: UITableViewController {
    
    @IBOutlet weak var trueLabel: UILabel!
    @IBOutlet weak var falseLabel: UILabel!
    
}
