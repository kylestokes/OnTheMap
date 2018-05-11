//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 4/26/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit

struct StudentLocation {
    
    // MARK: Properties
    
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mediaURL: String?
    var uniqueKey: String?
    var location: String?
    var objectID: String?
    
    // MARK: Initializers
    
    init(dictionary: [String:AnyObject]) {
        if let fName = dictionary["firstName"] as? String {
            firstName = fName
        }
        
        if let lName = dictionary["lastName"] as? String {
            lastName = lName
        }
        
        if let lat = dictionary["latitude"] as? Double {
            latitude = lat
        }
        
        if let long = dictionary["longitude"] as? Double {
            longitude = long
        }
        
        if let mediaLink = dictionary["mediaURL"] as? String {
            mediaURL = mediaLink
        }
        
        if let key = dictionary["uniqueKey"] as? String {
            uniqueKey = key
        }
        
        if let mapString = dictionary["mapString"] as? String {
            location = mapString
        }
        
        if let objectId = dictionary["objectId"] as? String {
            objectID = objectId
        }
    }
    
    static func studentLocationsFromResults(_ results: [[String:AnyObject]]) -> [StudentLocation] {
        
        var studentLocations = [StudentLocation]()
        
        // iterate through array of dictionaries, each StudentLocation is a dictionary
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
}
