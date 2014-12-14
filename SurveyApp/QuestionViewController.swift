//
//  DataViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 03/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

protocol QuestionViewControllerDelegate {
    func questionViewController(questionViewController: QuestionViewController, finishedQuestion: Question, withAnswer: Answer?)
}

class QuestionViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var question: Question!
    var answer: Answer? {
        get {
            return _answer
        }
        set {
            _answer = newValue
            nextButton.enabled = newValue != nil
        }
    }
    
    private var _answer: Answer?
    
    var delegate: QuestionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataLabel!.text = question.question_text
        self.nextButton.enabled = question.skippable || answer != nil
        self.backButton.enabled = false // fixme
        
        self.nextButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
        self.backButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
        
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
            dlg.questionViewController(self, finishedQuestion: self.question, withAnswer: self.answer)
        }
    }
    
}

