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

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser
    
    var userLocationInformations: UserLocation = UserLocation(long: 0.0,lat: 0.0,city: "",isoCountryCode: "",postalCode: "")
    var usersLocation = [String:CLLocation]()
    var usersInCircle = [String:CLLocation]()
    var usersInCircleTable = [NearUser]()
    
    
    @IBOutlet weak var longituteLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var nearUsersTableView: UITableView!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
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
    
        getLocationDetails(location: locations[0])
        printLocationDetails()
        
        getUsersLocation()
        getNearUsers(circle: 100, usersLocation: usersLocation, location: locations[0])
        
        for (key, value) in self.usersInCircle {
            self.usersInCircleTable.append(NearUser(uid:key,location:value))
        }
        self.nearUsersTableView.reloadData()
    }
    
    // Get current user City, PostalCode and Country code
    func getLocationDetails(location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil {
                print("Error getting location: \(error)")
            } else {
                let placeArray = placemarks as [CLPlacemark]!
                var placeMark: CLPlacemark!
                if ((placeArray?.count)! > 0) {
                    placeMark = placeArray?[0]
                    self.updateUserLocationInformations(location: location, placeMark: placeMark)
                }
            }
        }
    }
    
    func updateUserLocationInformations(location: CLLocation, placeMark: CLPlacemark?) {
        // Add location details to the user
        self.userLocationInformations.long = location.coordinate.longitude
        self.userLocationInformations.lat = location.coordinate.latitude
        
        if placeMark != nil {
            self.userLocationInformations.city = (placeMark?.locality!)!
            self.userLocationInformations.isoCountryCode = (placeMark?.isoCountryCode!)!
            self.userLocationInformations.postalCode = (placeMark?.postalCode!)!
        }
        
        ref.child("Users").child((user?.uid)!).child("Location").child("Lat").setValue("\(userLocationInformations.lat)")
        ref.child("Users").child((user?.uid)!).child("Location").child("Long").setValue("\(userLocationInformations.long)")
        
        ref.child("Users").child((user?.uid)!).child("Location").child("City").setValue("\(userLocationInformations.city)")
        ref.child("Users").child((user?.uid)!).child("Location").child("PostalCode").setValue("\(userLocationInformations.postalCode)")
        ref.child("Users").child((user?.uid)!).child("Location").child("isoCountryCode").setValue("\(userLocationInformations.isoCountryCode)")
    }
    
    func printLocationDetails() {
        self.cityLabel.text = "\(userLocationInformations.city)"
        self.countryLabel.text = "\(userLocationInformations.isoCountryCode)"
        self.longituteLabel.text = "\(userLocationInformations.long)"
        self.latitudeLabel.text = "\(userLocationInformations.lat)"
    }
    
    // Get the list of users and their location
    func getUsersLocation() {
        let usersRef = self.ref.child("Users")
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let json = JSON(snapshot.value!)
            for (index, object) in json {
                let lat = object["Location"]["Lat"].doubleValue
                let long = object["Location"]["Long"].doubleValue
                let loc = CLLocation(latitude: lat, longitude: long)
                self.usersLocation[index] = loc
            }
        })
    }
    
    // Find users around circle(m)
    func getNearUsers(circle: Double, usersLocation: [String:CLLocation], location: CLLocation){
        for user in usersLocation {
            if distanceBetweenTwoLocations(source: location, destination: user.value) < circle {
                self.usersInCircle[user.key] = user.value
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersInCircleTable.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.nearUsersTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        (cell.viewWithTag(4) as! UILabel).text = self.usersInCircleTable[indexPath.row].uid
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}

