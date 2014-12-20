//
//  AppDelegate.swift
//  SurveyApp
//
//  Created by Christian Kellner on 03/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ConsentViewControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("consent") == nil {
            println("Will get consent")
            
            let vc = storyboard.instantiateViewControllerWithIdentifier("ConsentVC") as ConsentViewController
            vc.delegate = self
            window?.rootViewController = vc
        } else {
            window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("Root") as? UIViewController
        }
        
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
    
    func didGiveConsent(vc: ConsentViewController) {
        //fixme: nice transition anomation
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "consent")
        defaults.synchronize()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewControllerWithIdentifier("Root") as UIViewController
        window?.rootViewController = homeVC
    }

}

