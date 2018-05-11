//
//  Shared.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 5/4/18.
//  with attribution to nsutanto
//  https://github.com/nsutanto/ios-OnTheMap/blob/master/OnTheMap/SharedData.swift
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit

class Shared{
    
    static let sharedInstance = Shared()
    var studentLocations: [StudentLocation] = []
    var currentUser: StudentLocation?
}
