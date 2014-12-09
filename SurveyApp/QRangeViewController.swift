//
//  QRangeViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 09/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class QRangeViewController: QuestionViewController {
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var rangeSlider: UISlider!
    @IBOutlet weak var maxLabel: UILabel!

    weak var rangeQuestion: QRange!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeQuestion = self.question as QRange
        
        minLabel.text = rangeQuestion.rangeMin.stringValue
        maxLabel.text = rangeQuestion.rangeMax.stringValue
        rangeSlider.minimumValue = rangeQuestion.rangeMin.floatValue
        rangeSlider.maximumValue = rangeQuestion.rangeMax.floatValue
    }
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        var value: NSNumber = rangeSlider.value
        valueLabel.text = value.stringValue
    }
}
