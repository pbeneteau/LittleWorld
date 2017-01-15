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
import SwiftyJSON

struct UserLocation {
    var long: CLLocationDegrees
    var lat: CLLocationDegrees
    var city: String
    var isoCountryCode: String
    var postalCode: String
}



func getUsersLocation (firebaseRef:FIRDatabaseReference) -> [String:CLLocationCoordinate2D] {
    var userLocation = [String:CLLocationCoordinate2D]()
    
    let usersRef = firebaseRef.child("Users")
    
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        let json = JSON(snapshot.value)
        print(json)
        for i in 0..<json.count {
            print(json[i]["Location"]["Lat"].intValue)
        }
        
    })
    
    return userLocation
}


func getNearUsers(circle: Int, usersLocation: NSDictionary, location: CLLocation) {
    switch circle {
    case 20:
        break
    case 50:
        break
    case 100:
        break
    case 200:
        break
    case 500:
        break
    default:
        break
    }
    
   //let distanceKiloMeters = (newLocation.distance(from: oldLocation))/1000
}









