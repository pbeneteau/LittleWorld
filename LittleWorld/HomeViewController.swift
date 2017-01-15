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

struct Typealiases {
    typealias JSONDict = [String:Any]
}

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser
    
    var userDict: [String:String] = [:]
    
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
    
    let coord1 = CLLocation(latitude: 52.45678, longitude: 13.98765)
    let coord2 = CLLocation(latitude: 48.77517989, longitude: 2.27792803)
    let coord3 = CLLocation(latitude: 48.77189, longitude: 2.270748)
    
    

    
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
        var userLocation:CLLocation = locations[0]
        
        let userLong = userLocation.coordinate.longitude;
        let userLat = userLocation.coordinate.latitude;
        
        userLocation = CLLocation(latitude: userLat, longitude: userLong)
        
        ref.child("Users").child((user?.uid)!).child("Location").setValue("\(userLocation)")
        
        let usersRef = ref.child("Users")
       
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for snap in snapshot.children {
                let userSnap = snap as! FIRDataSnapshot
                let uid = userSnap.key //the uid of each user
                self.userDict = userSnap.value as! [String : String] //child data
                let otherUserLocation = self.userDict["Location"]
                print("user = \(uid) is at location = \(otherUserLocation)")
            }
        })
        
        print(userDict)
        longituteLabel.text = "\(userLong)"
        latitudeLabel.text = "\(userLat)"
        
        // Get country the of current user
        getAdress(location: userLocation) { result in
            if let userCountry = result["Country"] as? String {
                self.countryLabel.text = "\(userCountry)"
            }
        }
        // Get city the of current user
        getAdress(location: userLocation) { result in
            
            if let userCity = result["City"] as? String {
                self.cityLabel.text = "\(userCity)"
            }
        }
        
        let coordinates = [coord1, coord2, coord3]
        
        let closestLocation: CLLocation = getClosestLocation(locations: coordinates, closestToLocation: userLocation)!

        let closestLong = closestLocation.coordinate.longitude
        let closestLat = closestLocation.coordinate.latitude
        
        closestLatitudeLabel.text = "\(closestLat)"
        closestLongitudeLabel.text = "\(closestLong)"
        
        // Get country the of closest user
        getAdress(location: closestLocation) { result in
            if let closestUserCountry = result["Country"] as? String {
                self.closestCountryLabel.text = "\(closestUserCountry)"
            }
        }
        // Get city the of closest user
        getAdress(location: closestLocation) { result in
            if let closestUserCity = result["City"] as? String {
                self.closestCityLabel.text = "\(closestUserCity)"
            }
        }
    }
    
    func getClosestLocation(locations: [CLLocation], closestToLocation location: CLLocation) -> CLLocation? {
        
        if let closestLocation: CLLocation = locations.min(by: { userLocation.distance(from: $0) < userLocation.distance(from: $1) }) {
            
            let distanceMeters: Int = Int(userLocation.distance(from: closestLocation))
            closestTitleLabel.text = " Closest user (\(distanceMeters)m)"

            return closestLocation
        } else {
            print("coordinates is empty")
            return nil
        }
    }
    
    
    func getAdress(location: CLLocation, completion: @escaping (Typealiases.JSONDict) -> ()) {
        
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            userLocation = locationManager.location!
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(userLocation) { (placemarks, error) -> Void in
                
                if error != nil {
                    print("Error getting location: \(error)")
                } else {
                    let placeArray = placemarks as [CLPlacemark]!
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    completion(placeMark.addressDictionary as! Typealiases.JSONDict)
                }
            }
        }
    }
}
