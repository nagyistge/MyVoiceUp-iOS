//
//  HomeViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 08/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

class HomeViewController : UIViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}


class HomeTableViewController: UITableViewController, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SurveyStats") as UITableViewCell
            return cell
        } else if indexPath.section == 1 {
            var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("NavigationCell") as UITableViewCell
            cell.textLabel?.text = "Take today's survey"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        } else if indexPath.section == 2 {
            var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("NavigationCell") as UITableViewCell
            cell.textLabel?.text = "Settings"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        }
        
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("NavigationCell") as UITableViewCell
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140
        }
        
        return 44
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("did select row at index path")
        if indexPath.section == 1 {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Survey") as SurveyViewController
//            vc.question = question
//            vc.delegate = self
            
            self.presentViewController(vc, animated: true, completion: {done in})
        }
    }

    
}