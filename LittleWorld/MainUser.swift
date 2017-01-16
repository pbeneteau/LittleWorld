//
//  MainUser.swift
//  LittleWorld
//
//  Created by antoine beneteau on 2017-01-16.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import CoreLocation
import MapKit


class MainUser {
    
    private let firebaseRef = FIRDatabase.database().reference()
    private var user = FIRAuth.auth()?.currentUser
    private var uid: String = ""
    private var name: String!
    private var lat: Double!
    private var long: Double!
    private var city: String!
    private var postalCode: String!
    private var countryCode: String!
    private var status: Bool!
    
    
    // Location
    func setLocation(location: CLLocation) {
        self.lat = location.coordinate.latitude
        self.long = location.coordinate.longitude
        self.getLocationDetails(location: location)
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
                    if let infos = placeMark {
                        self.city = infos.locality
                        self.countryCode = infos.isoCountryCode
                        self.postalCode = infos.postalCode
                        self.updateToFirebase()
                    }
                }
            }
        }
    }
    
    func updateToFirebase() {
        firebaseRef.child("Users").child(uid).child("Location").child("Lat").setValue("\(lat!)")
        firebaseRef.child("Users").child(uid).child("Location").child("Long").setValue("\(long!)")
        
        firebaseRef.child("Users").child(uid).child("Location").child("City").setValue("\(city!)")
        firebaseRef.child("Users").child(uid).child("Location").child("PostalCode").setValue("\(postalCode!)")
        firebaseRef.child("Users").child(uid).child("Location").child("isoCountryCode").setValue("\(countryCode!)")
    }
    
    func checkConnectionState() {
        
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = FIRDatabase.database().reference(withPath: "Users/\(uid)/Connections")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = FIRDatabase.database().reference(withPath: "Users/\(uid)/Connections/LastOnline")
        
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            // only handle connection established (or I've reconnected after a loss of connection)
            guard let connected = snapshot.value as? Bool, connected else {
                return
            }
            // add this device to my connections list
            // this value could contain info about the device or a timestamp instead of just true
            let con = myConnectionsRef.child("Connected")
            con.setValue("true")
            
            // when this device disconnects, remove it
            con.onDisconnectSetValue("false")
            // when I disconnect, update the last time I was seen online
            lastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp())
        })
    }
    
    
    // Get 
    func getUid() -> String {
        return self.uid
    }
    func getName() -> String {
        return self.name
    }
    func getLat() -> Double {
        return self.lat
    }
    func getLong() -> Double {
        return self.long
    }
    func getCity() -> String {
        return self.city
    }
    func getPostalCode() -> String {
        return self.postalCode
    }
    func getCountryCode() -> String {
        return self.countryCode
    }
    func getStatus() -> Bool {
        return self.status
    }
    
    init() {
        uid = user!.uid
        lat = 0.0
        long = 0.0
        name = ""
        city = ""
        postalCode = ""
        countryCode = ""
    }
    
}
