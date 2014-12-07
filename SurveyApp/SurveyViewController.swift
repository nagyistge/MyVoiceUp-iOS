//
//  RootViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 03/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController, UIPageViewControllerDelegate, QuestionViewControllerDelegate {

    var pageViewController: UIPageViewController?
    var survey: Survey!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PageController setup
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
    
        survey = DataStore.sharedInstance.survey! //FIXME
        
        let q = survey.questions.first!
        let vc = makeQuestionViewController(q)
        let viewControllers = [vc]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })

        self.addChildViewController(self.pageViewController!)
        self.container.addSubview(self.pageViewController!.view)
        self.pageViewController!.view.frame = self.container.bounds
        self.pageViewController!.didMoveToParentViewController(self)
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
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
        let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionViewConroller") as QuestionViewController
        vc.question = question
        vc.delegate = self
        return vc
    }
    
    // MARK: - QuestionViewController delegate methods
    func questionViewController(questionViewController: QuestionViewController, finishedQuestion:Question) {
        var idx = find(survey.questions, finishedQuestion)!
        
        if (idx + 1 < survey.questions.count) {
            let vc = makeQuestionViewController(survey.questions[idx+1])
            self.pageViewController!.setViewControllers([vc], direction: .Forward, animated: true, completion: {done in })
        }
    }

}
