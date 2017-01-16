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
import MapKit
import SwiftyJSON

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {

    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser

    var mainUser: MainUser!
    var users = Users()
    
    @IBOutlet weak var longituteLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var nearUsersTableView: UITableView!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    var inCircleUsersTable = [UserTable]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FIRAuth.auth()?.currentUser) != nil // Check if user already logged in
        {
            print("user already logged in -> firstVC")
            
            transitionSegue.segue.switchToNavigationController() // Segue if true
        }

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        mainUser = MainUser()
        
        mainUser.checkConnectionState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disconnectAction(_ sender: Any) {
        try!FIRAuth.auth()?.signOut() // Logout
        print("user did logout of facebook")
        transitionSegue.segue.switchToLoginview()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.mainUser.setLocation(location: locations[0])
        self.users.loadUsers()
        self.users.loadInCircleUsersList(location: locations[0], _uid: (user?.uid)!, circle: 100)
        printLocationDetails()
        
        self.inCircleUsersTable.removeAll()
        for (uid,user) in self.users.getInCircleUsersList() {
            self.inCircleUsersTable.append(UserTable(uid: uid, user: user))
        }
        self.nearUsersTableView.reloadData()
        
    }

    
    func printLocationDetails() {
        self.cityLabel.text = "\(mainUser.getCity())"
        self.countryLabel.text = "\(mainUser.getCountryCode())"
        self.longituteLabel.text = "\(mainUser.getLong())"
        self.latitudeLabel.text = "\(mainUser.getLat())"
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

