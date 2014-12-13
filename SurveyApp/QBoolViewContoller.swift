//
//  QBoolViewContoller.swift
//  SurveyApp
//
//  Created by Christian Kellner on 08/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

protocol QBoolAnswerViewControllerDelegate {
    func qboolAnswerViewController(viewController: QBoolAnswerViewController, madeChoice: Bool);
}

class QBoolViewController: QuestionViewController, QBoolAnswerViewControllerDelegate {
    
    weak var txtChoiceQ: QBoolChoice!
    weak var answerViewController: QBoolAnswerViewController!
    
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtChoiceQ = super.question as QBoolChoice
        println("view did load finished")
        answerViewController.delegate = self
        answerViewController.trueLabel.text = txtChoiceQ.trueChoice
        answerViewController.falseLabel.text = txtChoiceQ.falseChoice
    }
    
    func qboolAnswerViewController(viewController: QBoolAnswerViewController, madeChoice: Bool) {
    
        if let a = answer as? ValuedAnswer<Bool> {
            a.value = madeChoice
        } else {
            answer = ValuedAnswer<Bool>(question: self.question, value: madeChoice)
        }
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
    
    var delegate: QBoolAnswerViewControllerDelegate?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let d = delegate {
            d.qboolAnswerViewController(self, madeChoice: indexPath.row == 1)
        }
    }
    
}
