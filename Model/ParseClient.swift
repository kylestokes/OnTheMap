//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 5/4/18.
//  with attribution to nsutanto
//  https://github.com/nsutanto/ios-OnTheMap/blob/master/OnTheMap/ParseClient.swift
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit

class ParseClient: NSObject  {
    
    // shared session
    var session = URLSession.shared
    
    // Store single student location
    var studentLocation: StudentLocation?
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // Get all student locations
    func getStudentLocations(completionHandlerLocations: @escaping (_ result: [StudentLocation]?, _ error: NSError?)
        -> Void) {
        
        // 1. Specify parameters
        var request = URLRequest(url: URL(string: "\(ParseConstants.Constants.ApiScheme)://\(ParseConstants.Constants.ApiHost)\(ParseConstants.Constants.ApiPath)\(ParseConstants.Methods.StudentLocation)?order=-updatedAt&limit=100")!)
        request.addValue(ParseConstants.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLocations(nil, error)
            } else {
                
                if let results = parsedResult?["results"] as? [[String:AnyObject]] {
                    
                    Shared.sharedInstance.studentLocations = StudentLocation.studentLocationsFromResults(results)
                    
                    completionHandlerLocations(Shared.sharedInstance.studentLocations, nil)
                } else {
                    completionHandlerLocations(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // Get a single student Location
    func getStudentLocation(completionHandlerLocation: @escaping (_ result: StudentLocation?, _ error: NSError?)
        -> Void) {
        
        // 1. Specify parameters
        let accountKey = UdacityClient.sharedInstance().accountKey
        var request = URLRequest(url: URL(string: "\(ParseConstants.Constants.ApiScheme)://\(ParseConstants.Constants.ApiHost)\(ParseConstants.Constants.ApiPath)\(ParseConstants.Methods.StudentLocation)?where=%7B%22uniqueKey%22%3A%22\(accountKey!)%22%7D")!)
        request.addValue(ParseConstants.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLocation(nil, error)
            } else {
                
                if let results = parsedResult?["results"] as? [[String:AnyObject]] {
                    
                    Shared.sharedInstance.studentLocations = StudentLocation.studentLocationsFromResults(results)
                    
                    // Check if there are any previous posts by user
                    if (Shared.sharedInstance.studentLocations.count > 0) {
                        self.studentLocation = Shared.sharedInstance.studentLocations[0]
                        Shared.sharedInstance.currentUser = self.studentLocation!
                        completionHandlerLocation(self.studentLocation, nil)
                    }
                    else {
                        // No previous posts by user so return current user studentLocation
                        completionHandlerLocation(Shared.sharedInstance.currentUser, nil)
                    }
                } else {
                    completionHandlerLocation(nil, NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation"]))
                }
            }
        }
    }
    
    // Post new location
    func postNewLocation(studentLocation: StudentLocation, completionHandlerPostLocation: @escaping (_ error: NSError?) -> Void) {
        
        // 1. Specify parameters
        var request = URLRequest(url: URL(string: "\(ParseConstants.Constants.ApiScheme)://\(ParseConstants.Constants.ApiHost)\(ParseConstants.Constants.ApiPath)\(ParseConstants.Methods.StudentLocation)")!)
        request.addValue(ParseConstants.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(studentLocation.uniqueKey!)\", \"firstName\": \"\(studentLocation.firstName!)\", \"lastName\": \"\(studentLocation.lastName!)\",\"mapString\": \"\(studentLocation.location!)\", \"mediaURL\": \"\(studentLocation.mediaURL!)\",\"latitude\": \(studentLocation.latitude!), \"longitude\": \(studentLocation.longitude!)}".data(using: String.Encoding.utf8)
        
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerPostLocation(error)
            } else {
                
                /* GUARD: Is the "createdAt" key in our result? */
                guard let createdAt = parsedResult?["createdAt"] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postNewLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postNewLocation"]))
                    return
                }
                
                guard let objectID = parsedResult?["objectId"] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postNewLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postNewLocation"]))
                    return
                }
                
                if (objectID != "" && createdAt != "") {
                    completionHandlerPostLocation(nil)
                } else {
                    completionHandlerPostLocation(NSError(domain: "postNewLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postNewLocation"]))
                }
            }
        }
    }
    
    // Update student location
    func updateStudentLocation(studentLocation: StudentLocation, completionHandlerPutLocation: @escaping (_ error: NSError?) -> Void) {
        
        // 1. Specify parameters
        var request = URLRequest(url: URL(string: "\(ParseConstants.Constants.ApiScheme)://\(ParseConstants.Constants.ApiHost)\(ParseConstants.Constants.ApiPath)\(ParseConstants.Methods.StudentLocation)/\(studentLocation.objectID!)")!)
        request.httpMethod = "PUT"
        request.addValue(ParseConstants.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(studentLocation.uniqueKey!)\", \"firstName\": \"\(studentLocation.firstName!)\", \"lastName\": \"\(studentLocation.lastName!)\",\"mapString\": \"\(studentLocation.location!)\", \"mediaURL\": \"\(studentLocation.mediaURL!)\",\"latitude\": \(studentLocation.latitude!), \"longitude\": \(studentLocation.longitude!)}".data(using: String.Encoding.utf8)
        
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerPutLocation(error)
            } else {
                
                /* GUARD: Is the "updated at" key in our result? */
                guard let updatedAt = parsedResult?["updatedAt"] as? String else {
                    completionHandlerPutLocation(NSError(domain: "updateStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updateStudentLocation"]))
                    return
                }
                
                if updatedAt != "" {
                    completionHandlerPutLocation(nil)
                } else {
                    completionHandlerPutLocation(NSError(domain: "updateStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updateStudentLocation"]))
                }
            }
        }
    }
    
    // This abstracts the guard statements for requests to one location
    private func performRequest(request: URLRequest,
                                completionHandlerRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
        -> URLSessionDataTask {
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                func sendError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                }
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    sendError("There was an error with your request: \(error!)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    sendError("Your request returned a status code : \(String(describing: httpError))")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    sendError("No data was returned by the request!")
                    return
                }
                
                print(String(data: data, encoding: String.Encoding.utf8)!)
                
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerRequest)
            }
            
            task.resume()
            
            return task
    }
    
    // When given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
