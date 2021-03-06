//
//  RootViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 03/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

protocol SurveyViewControllerDelegate {
    func surveyViewController(viewController: SurveyViewController, forSurvey survey: Survey, withResponse response: Response)
}

class SurveyViewController: UIViewController, UIPageViewControllerDelegate, QuestionViewControllerDelegate {

    var pageViewController: UIPageViewController?
    var survey: Survey!
    var response: Response!
    
    var delegate: SurveyViewControllerDelegate?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var questionProgress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PageController setup
        self.pageViewController!.delegate = self
        self.pageViewController!.automaticallyAdjustsScrollViewInsets = false
        
        survey = DataStore.sharedInstance.survey! //FIXME
        response = Response(survey_id: survey.identifier)
        
        let q = survey.questions.first!
        let vc = makeQuestionViewController(q)
        let viewControllers = [vc]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        setProgress(0)
    }

    // MARK: - UIPageViewController delegate methods
    func pageViewController(pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [AnyObject],
        transitionCompleted completed: Bool) {
            if completed {
                let currentViewController = pageViewController.viewControllers[0] as QuestionViewController
                self.lblHeader.text = currentViewController.dataLabel.text
            }
    }
    
    func makeQuestionViewController(question: Question)  -> QuestionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var result = ""
        if let q = question as? QTextChoice {
            result = "QTextChoicesViewConroller"
        } else if let q = question as? QBoolChoice {
            result = "QBoolViewConroller"
        } else if let q = question as? QAudioRecording {
            result = "QAudioViewConroller"
        } else if let q = question as? QRange {
            result = "QRangeViewConroller"
        } else if let q = question as? QImgChoice {
            result = "QImgChoiceViewController"
        }
        
        let vc = storyboard.instantiateViewControllerWithIdentifier(result) as QuestionViewController
        vc.question = question
        vc.delegate = self
        return vc
    }
        
    func setProgress(questionIndex: Int) {
        questionProgress.progress = (Float(questionIndex)) / Float(survey.questions.count)
        lblHeader.text = "Question \(questionIndex + 1) of \(survey.questions.count)"
    }
    
    // MARK: - QuestionViewController delegate methods
    func questionViewController(questionViewController: QuestionViewController, finishedQuestion:Question, withAnswer: Answer?) {
        
        if let a = withAnswer {
            response.addAnswer(a)
        }
        
        var idx = find(survey.questions, finishedQuestion)!
        
        if (idx + 1 < survey.questions.count) {
            let vc = makeQuestionViewController(survey.questions[idx+1])
            self.pageViewController!.setViewControllers([vc], direction: .Forward, animated: true, completion: {done in })
            self.setProgress(idx + 1)
            
        } else if (idx + 1 == survey.questions.count) {
            if let d = self.delegate {
                d.surveyViewController(self, forSurvey: survey, withResponse: response)
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if let destVC = segue.destinationViewController as? UIPageViewController {
            self.pageViewController = destVC
        }
    }

}

