//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 5/4/18.
//  with attribution to nsutanto
//  https://github.com/nsutanto/ios-OnTheMap/blob/master/OnTheMap/UdacityClient.swift
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation

class UdacityClient {
    // shared session
    var session = URLSession.shared
    // store logged in user's account key
    var accountKey: String?
    // store user's session ID
    var sessionID: String?
    
    // Login with Udacity
    func loginUdacity(_ email: String, _ password: String, completionHandlerLogin: @escaping (_ error: NSError?) -> Void) {
        
        // 1. Specify parameters
        var request = URLRequest(url: URL(string: "\(UdacityConstants.Constants.ApiScheme)://\(UdacityConstants.Constants.ApiHost)\(UdacityConstants.Constants.ApiPath)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLogin(error)
            } else {
                /* GUARD: Is the "account" key in our result? */
                guard let accountDictionary = parsedResult?["account"] as? [String:AnyObject] else {
                    return
                }
                
                /* GUARD: Is the "registered" key in our result? */
                guard let registered = accountDictionary["registered"] as? Bool else {
                    return
                }
                
                /* GUARD: Is the "key" key in our result? */
                guard let accountKey = accountDictionary["key"] as? String else {
                    return
                }
                
                /* GUARD: Is the "session" key in our result? */
                guard let sessionDictionary = parsedResult?["session"] as? [String:AnyObject] else {
                    return
                }
                
                /* GUARD: Is the "id" key in our result? */
                guard let sessionID = sessionDictionary["id"] as? String else {
                    return
                }
                
                // If account is registered, we can login
                if registered {
                    self.accountKey = accountKey
                    self.sessionID = sessionID
                    
                    completionHandlerLogin(nil)
                }
                else {
                    
                    // Account is not registered
                    let errorMsg = "Account is not registered"
                    let userInfo = [NSLocalizedDescriptionKey : errorMsg]
                    completionHandlerLogin(NSError(domain: errorMsg, code: 2, userInfo: userInfo))
                    
                }
            }
        }
    }
    
    // Logout with Udacity
    func logoutUdacity(completionHandlerLogout: @escaping (_ error: NSError?) -> Void) {
        
        // 1. Specify parameters
        var request = URLRequest(url: URL(string: "\(UdacityConstants.Constants.ApiScheme)://\(UdacityConstants.Constants.ApiHost)\(UdacityConstants.Constants.ApiPath)")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLogout(error)
            } else {
                completionHandlerLogout(nil)
            }
        }
    }
    
    // Get current student data
    func getCurrentStudentData(completionHandlerLocation: @escaping (_ result: StudentLocation?, _ error: NSError?)
        -> Void) {
        
        // 1. Specify parameters
        let accountKey = self.accountKey!
        var request = URLRequest(url: URL(string: "\(UdacityConstants.Constants.ApiScheme)://\(UdacityConstants.Constants.ApiHost)\(UdacityConstants.Constants.ApiUsers)\(accountKey)")!)
        request.addValue(ParseConstants.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLocation(nil, error)
            } else {
                
                /* GUARD: Is the "user" key in our result? */
                guard let results = parsedResult?["user"] as? [String:AnyObject] else {
                    completionHandlerLocation(nil, NSError(domain: "getCurrentStudentData parsing — no results!", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation"]))
                    return
                }
                
                /* GUARD: Is the "first_name" key in results? */
                guard let firstName = results["first_name"] as? String else {
                    completionHandlerLocation(nil, NSError(domain: "getCurrentStudentData parsing — no first_name!", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation"]))
                    return
                }
                
                /* GUARD: Is the "last_name" key in results? */
                guard let lastName = results["last_name"] as? String else {
                    completionHandlerLocation(nil, NSError(domain: "getCurrentStudentData parsing — no last_name!", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation"]))
                    return
                }
                
                // Set current user
                let currentUserProperties: [String: AnyObject] = [
                    "firstName" : firstName as AnyObject,
                    "lastName" : lastName as AnyObject,
                ]
                var currentUser = StudentLocation.studentLocationsFromResults([currentUserProperties])
                Shared.sharedInstance.currentUser = currentUser[0]
                completionHandlerLocation(Shared.sharedInstance.currentUser!, nil)
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
                    DispatchQueue.main.async {
                        completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                    }
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
                
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range) /* subset response data! */
                print(String(data: newData, encoding: String.Encoding.utf8)!)
                
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerRequest)
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
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
