//
//  QTextChoicesViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 07/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class QTextChoiceViewController: QuestionViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var txtChoiceQ: QTextChoice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        txtChoiceQ = self.question as QTextChoice
        
        if let a = self.answer {
            println("Have answer already")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TextChoiceCell") as QTextChoiceCell
        
        cell.choiceLabel?.text = txtChoiceQ.choices[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txtChoiceQ.choices.count
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

class QTextChoiceCell: UITableViewCell {
    @IBOutlet weak var choiceLabel: UILabel!
}