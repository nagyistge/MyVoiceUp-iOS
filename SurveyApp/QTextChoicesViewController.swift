//
//  QTextChoicesViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 07/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class QTextChoiceViewController: QuestionViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var txtChoiceQ: QTextChoice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView!.dataSource = self
        txtChoiceQ = self.question as QTextChoice
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TextChoiceCell") as QTextChoiceCell
        
        cell.choiceLabel?.text = txtChoiceQ.choices[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txtChoiceQ.choices.count
    }
}

class QTextChoiceCell: UITableViewCell {
    @IBOutlet weak var choiceLabel: UILabel!
}