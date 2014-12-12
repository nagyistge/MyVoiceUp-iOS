//
//  DataViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 03/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

protocol QuestionViewControllerDelegate {
    func questionViewController(questionViewController: QuestionViewController, finishedQuestion:Question)
}

class QuestionViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var question: Question!
    var response: Response!

    var delegate: QuestionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataLabel!.text = question.question_text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK - Button Actions
    @IBAction func nextButtonUp(sender: AnyObject) {
        if let dlg = delegate {
            dlg.questionViewController(self, finishedQuestion: self.question)
        }
    }
    
}

