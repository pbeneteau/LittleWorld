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
    var long: CLLocationDegrees
    var lat: CLLocationDegrees
    var city: String
    var isoCountryCode: String
    var postalCode: String
}



// Find users around circle(m)
func getNearUsers(circle: Double, usersLocation: [String:CLLocation], location: CLLocation) {
    for user in usersLocation {
        if distanceBetweenTwoLocations(source: location, destination: user.value) < circle {
            print("\(user.key) à coté de vous")
        }
    }
}

// Distance between current user and other user
func distanceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double{
    
    let distanceMeters = source.distance(from: destination)
    return distanceMeters
    
}






