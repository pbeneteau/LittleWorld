//
//  HomeViewController.swift
//  LittleWorld
//
//  Created by Paul Bénéteau on 13/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import SwiftyJSON
import PermissionScope

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {

    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser

    var mainUser: MainUser!
    var users = Users()
    
    let pscope = PermissionScope()
    
    @IBOutlet weak var longituteLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var nearUsersTableView: UITableView!
    
    
    var inCircleUsersTable = [UserTable]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pscope.addPermission(LocationWhileInUsePermission(), message: "We use this to track\r\nwhere you live")
        
        
        pscope.show({ finished, results in
            print("got results \(results)")
        }, cancelled: { (results) -> Void in
            print("thing was cancelled")
        })
        
        
        mainUser = MainUser()
        
        mainUser.checkConnectionState()

        var r = Location.getLocation(withAccuracy: .house, frequency: .byDistanceIntervals(meters: 1), timeout: nil, onSuccess: { (location) in
            self.mainUser.setLocation(location: location)
            self.printLocationDetails()
        }) { (last, err) in
            print("err \(err)")
        }
        r.onAuthorizationDidChange = { newStatus in
            print("New status \(newStatus)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disconnectAction(_ sender: Any) {
        mainUser.disconnect()
    }
    

    
    func printLocationDetails() {
        self.cityLabel.text = "City: \(mainUser.getCity())"
        self.countryLabel.text = "Country: \(mainUser.getCountryCode())"
        self.longituteLabel.text = "Longitude: \(mainUser.getLong())"
        self.latitudeLabel.text = "Latitude: \(mainUser.getLat())"
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inCircleUsersTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.nearUsersTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        (cell.viewWithTag(4) as! UILabel).text = (self.inCircleUsersTable[indexPath.row].user as User).name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "login" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = self
        }
    }

}

