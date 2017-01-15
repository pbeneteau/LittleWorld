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


class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser
    
    var userLocationInformations: UserLocation!
    
    var tab_loc = [String:String]()
    
    var locationsArray = [String]()
    
    
    @IBOutlet weak var longituteLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var closestTitleLabel: UILabel!
    
    @IBOutlet weak var closestLongitudeLabel: UILabel!
    @IBOutlet weak var closestLatitudeLabel: UILabel!
    @IBOutlet weak var closestCountryLabel: UILabel!
    @IBOutlet weak var closestCityLabel: UILabel!
    
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
        
        updateUserLocationInformations(location: locations[0])
        
        ref.child("Users").child((user?.uid)!).child("Location").setValue("\(userLocationInformations.location)")
        
        
        // Get all users Location
        let usersLocation = getUsersLocation(firebaseRef: self.ref)
        
        
        let closestLocation: CLLocation = getClosestLocation(locations: coordinates, closestToLocation: userLocation)!
        
        let closestLong = closestLocation.coordinate.longitude
        let closestLat = closestLocation.coordinate.latitude
        
        closestLatitudeLabel.text = "\(closestLat)"
        closestLongitudeLabel.text = "\(closestLong)"
        
    }
    
    func updateUserLocationInformations(location: CLLocation) {
        // Location CLLocation
        self.userLocationInformations.location = location
        self.userLocationInformations.long = userLocationInformations.location.coordinate.longitude
        self.userLocationInformations.lat = userLocationInformations.location.coordinate.latitude
        
        
        // Get user adress
        getAddress(locationManager: locationManager, location: userLocationInformations.location) { result in
            if let UserCity = result["City"] as? String {
                self.userLocationInformations.city = "\(UserCity)"
            }
        }
        // Get user adress
        getAddress(locationManager: locationManager, location: userLocationInformations.location) { result in
            if let UserCountry = result["Country"] as? String {
                self.userLocationInformations.country = "\(UserCountry)"
            }
        }
        
        self.cityLabel.text = "\(userLocationInformations.city)"
        self.countryLabel.text = "\(userLocationInformations.country)"
        self.longituteLabel.text = "\(userLocationInformations.long)"
        self.latitudeLabel.text = "\(userLocationInformations.lat)"
    }
}
