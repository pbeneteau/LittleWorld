//
//  Utils.swift
//  LittleWorld
//
//  Created by Paul Bénéteau on 15/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

struct UserLocation {
    var location: CLLocation
    var long: CLLocationDegrees
    var lat: CLLocationDegrees
    var city: String
    var country: String
}

struct Typealiases {
    typealias JSONDict = [String:Any]
}


func getAddress(locationManager: CLLocationManager, location: CLLocation, completion: @escaping (Typealiases.JSONDict) -> ()) {
    
    locationManager.requestWhenInUseAuthorization()
    if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            
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

func getUsersLocation (firebaseRef:FIRDatabaseReference) -> [String:String] {
    var userLocation = [String:String]()
    
    let usersRef = firebaseRef.child("Users")
    
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        for snap in snapshot.children {
            let userSnap = snap as! FIRDataSnapshot
            let uid = userSnap.key //the uid of each user
            let userDict = userSnap.value as! [String:String] //child data
            let location = userDict["Location"]
            
            userLocation[uid] = location
        }
    })
    
    return userLocation
}

func getClosestLocation(userLocation:CLLocation, locations: [CLLocation], closestToLocation location: CLLocation) -> CLLocation? {
    
    if let closestLocation: CLLocation = locations.min(by: { userLocation.distance(from: $0) < userLocation.distance(from: $1) }) {
        
        let distanceMeters: Int = Int(userLocation.distance(from: closestLocation))
        closestTitleLabel.text = " Closest user (\(distanceMeters)m)"
        
        return closestLocation
    } else {
        print("coordinates is empty")
        return nil
    }
}


