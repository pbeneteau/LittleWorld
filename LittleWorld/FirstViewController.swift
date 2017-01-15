//
//  FirstViewController.swift
//  LittleWorld
//
//  Created by Paul Bénéteau on 13/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController, UIViewControllerTransitioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        if (FIRAuth.auth()?.currentUser) != nil // Check if user already logged in
        {
            print("user already logged in -> firstVC")
            
            transitionSegue.segue.switchToNavigationController() // Segue if true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "login" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = self
        }
    }
}
