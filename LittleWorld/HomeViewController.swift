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
    
    var userLocationInformations: UserLocation = UserLocation(long: 0.0,lat: 0.0,city: "",country: "",postalCode: "")
    
    
    
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
    
        getLocationDetails(location: locations[0])
        printLocationDetails()
        
        let usersLocation = getUsersLocation(firebaseRef: self.ref) as NSDictionary
        
    }
    
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
            self.userLocationInformations.country = (placeMark?.country!)!
            self.userLocationInformations.postalCode = (placeMark?.postalCode!)!
        }
        
        ref.child("Users").child((user?.uid)!).child("Location").child("Lat").setValue("\(userLocationInformations.lat)")
        ref.child("Users").child((user?.uid)!).child("Location").child("Long").setValue("\(userLocationInformations.long)")
        
        ref.child("Users").child((user?.uid)!).child("Location").child("City").setValue("\(userLocationInformations.city)")
        ref.child("Users").child((user?.uid)!).child("Location").child("PostalCode").setValue("\(userLocationInformations.postalCode)")
        ref.child("Users").child((user?.uid)!).child("Location").child("Country").setValue("\(userLocationInformations.country)")
    }
    
    func printLocationDetails() {
        self.cityLabel.text = "\(userLocationInformations.city)"
        self.countryLabel.text = "\(userLocationInformations.country)"
        self.longituteLabel.text = "\(userLocationInformations.long)"
        self.latitudeLabel.text = "\(userLocationInformations.lat)"
    }
}
