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

struct NearUser {
    var uid: String
    var location: CLLocation
}

// Distance between current user and other user
func distanceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double{
    
    let distanceMeters = source.distance(from: destination)
    return distanceMeters
    
}

func loadData(ref: FIRDatabaseReference, childURL:String?, completionHandler: @escaping (AnyObject?) -> ()) {
    ref.observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
        if snapshot.value is NSNull {
            completionHandler(nil)
        } else {
            completionHandler(snapshot.value as AnyObject?)
        }
    }
}






