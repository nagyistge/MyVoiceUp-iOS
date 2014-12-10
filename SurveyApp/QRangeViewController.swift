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
    
    var step: Float = 1.0
    var offset: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeQuestion = self.question as QRange
        
        minLabel.text = rangeQuestion.rangeMin.stringValue
        maxLabel.text = rangeQuestion.rangeMax.stringValue
        
        let vMin = rangeQuestion.rangeMin.floatValue
        let vMax = rangeQuestion.rangeMax.floatValue
        step = rangeQuestion.rangeStep.floatValue
        
        let steps: Float = (vMax - vMin) / step
     
        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = steps
        
        offset = vMin
        
        rangeSlider.value = 0
        valueLabel.text = minLabel.text
    }
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        let stepper = rangeSlider.value
        let curValue = offset + round(stepper) * step
        
        var value: NSNumber = curValue
        valueLabel.text = value.stringValue
    }
}
