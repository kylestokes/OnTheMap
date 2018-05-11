//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 4/17/18.
//  with attribution to nsutanto
//  https://github.com/nsutanto/ios-OnTheMap/blob/master/OnTheMap/UpdateURLViewController.swift
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, MKMapViewDelegate {
    var latitude: Double!
    var longitude: Double!
    var location: String!
    var mediaURL: String!
    @IBOutlet weak var finish: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func addLocation(_ sender: UIButton) {
        
        if let studentLocation = Shared.sharedInstance.currentUser {
            var newStudentLocation = studentLocation
            newStudentLocation.latitude = latitude
            newStudentLocation.longitude = longitude
            newStudentLocation.mediaURL = mediaURL
            newStudentLocation.location = location
            newStudentLocation.uniqueKey = UdacityClient.sharedInstance().accountKey!
            
            if studentLocation.latitude == nil || studentLocation.longitude == nil {
                let activityIndicator = ActivityIndicator.displaySpinner(onView: self.view)
                ParseClient.sharedInstance().postNewLocation(studentLocation: newStudentLocation, completionHandlerPostLocation: { (error) in
                    if let error = error {
                        print(error)
                        self.showAlert(title: "🤨", message: "Unable to post location. Try again!")
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                    ActivityIndicator.removeSpinner(spinner: activityIndicator)
                })
            } else {
                let activityIndicator = ActivityIndicator.displaySpinner(onView: self.view)
                ParseClient.sharedInstance().updateStudentLocation(studentLocation: newStudentLocation, completionHandlerPutLocation: { (error) in
                    if let error = error {
                        print(error)
                        self.showAlert(title: "🤨", message: "Unable to update location. Try again!")
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                    ActivityIndicator.removeSpinner(spinner: activityIndicator)
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Config UI
        finish.layer.cornerRadius = 5
        let barButton = UIBarButtonItem()
        barButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        
        configNewLocation()
        checkIfUserPostExists()
    }
    
    func checkIfUserPostExists() {
        ParseClient.sharedInstance().getStudentLocation(completionHandlerLocation: { (studentLocation, error) in
            if let error = error {
                print(error)
                self.showAlert(title: "🤨", message: "Unable to find your posts")
            }
            
            if let studentLocation = studentLocation {
                print(studentLocation)
            }
        })
    }
    
    func configNewLocation() {
        // Center map
        let center = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        // Add pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = location
        self.mapView.addAnnotation(annotation)
        mapView.selectAnnotation(mapView.annotations[0], animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
