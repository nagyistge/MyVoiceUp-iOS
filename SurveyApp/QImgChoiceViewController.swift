//
//  QImgChoiceViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 09/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit


class QImgChoiceViewController: QuestionViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var imgChoiceQ: QImgChoice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        imgChoiceQ = self.question as QImgChoice
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ImageChoiceCell") as QImgChoiceCell
        
        let choice = imgChoiceQ.choices[indexPath.row]
        
        cell.choiceLabel?.text = choice.text
        cell.imageView?.image =  UIImage(named: choice.image)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgChoiceQ.choices.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        if self.answer == nil {
            self.answer = ValuedAnswer<Int>(question: self.question, value: indexPath.row)
        } else {
            let a = self.answer as ValuedAnswer<Int>
            a.value = indexPath.row
        }
        
    }
    
}

class QImgChoiceCell: UITableViewCell {
    @IBOutlet weak var choiceImage: UIImageView!
    @IBOutlet weak var choiceLabel: UILabel!
}