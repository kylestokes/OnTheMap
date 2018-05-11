//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 4/17/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class MapViewController: UIViewController, MKMapViewDelegate, SFSafariViewControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIBarButtonItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMap()
    }
    
    func createMapPinsFromStudentLocations(locations: [StudentLocation]) {
        
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            
            guard let lat = location.latitude else {
                continue
            }
            
            guard let long = location.longitude else {
                continue
            }
            
            let latitude = CLLocationDegrees(lat)
            let longitude = CLLocationDegrees(long)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            guard let fName = location.firstName else {
                continue
            }
            
            guard let lName = location.lastName else {
                continue
            }
            
            annotation.title = "\(fName) \(lName)"
            annotation.subtitle = location.mediaURL
            
            // Check if title or subtitle exist
            if annotation.title != "" && annotation.subtitle != "" {
                // Finally we place the annotation in an array of annotations
                annotations.append(annotation)
            }
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func configureMap() {
        let activityIndicator = ActivityIndicator.displaySpinner(onView: self.view)
        ParseClient.sharedInstance().getStudentLocations(completionHandlerLocations: { (studentLocations, error) in
            if let error = error {
                print(error)
                self.showAlert(title: "🤨", message: "Unable to get student locations. Try refreshing!")
            } else {
                self.createMapPinsFromStudentLocations(locations: studentLocations!)
            }
            ActivityIndicator.removeSpinner(spinner: activityIndicator)
        })
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {

            if let toOpen = view.annotation?.subtitle! {
                if toOpen.contains("http") {
                    let url = URL(string: toOpen)
                    let safariView = SFSafariViewController(url: url!)
                    self.present(safariView, animated: true, completion: nil)
                } else {
                    self.showAlert(title: "🤨", message: "Invalid URL")
                }
            }
        }
    }
}

extension MapViewController {
    @objc func refreshData() {
        configureMap()
    }
    
    @objc func addNewPin() {
        let findLocationView = storyboard?.instantiateViewController(withIdentifier: "FindLocation")
        present(findLocationView!, animated: true, completion: nil)
    }
    
    @objc func logout() {
        let activityIndicator = ActivityIndicator.displaySpinner(onView: self.view)
        UdacityClient.sharedInstance().logoutUdacity(completionHandlerLogout: { (error) in
            if let error = error {
                print(error)
                self.showAlert(title: "🤨", message: "Unable to logout")
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            ActivityIndicator.removeSpinner(spinner: activityIndicator)
        })
    }
    
    func configureUIBarButtonItems() {
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
        let addPin = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPin))
        self.navigationItem.rightBarButtonItems = [refresh, addPin]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
    }
}
