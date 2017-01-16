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


// Distance between current user and other user
func distanceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double {
    
    let distanceMeters = source.distance(from: destination)
    return distanceMeters
    
}







