//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 4/17/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import CoreLocation

class FindLocationViewController: UIViewController {
    
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var url: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    @IBAction func findLocation(_ sender: UIButton) {
        
        // Are location and URL empty?
        if (location.text?.isEmpty)! || (url.text?.isEmpty)! {
            self.showAlert(title: "Uhh...", message: "Please fill in both location and URL.")
        } else {
            let activityIndicator = ActivityIndicator.displaySpinner(onView: self.view)
            // Forward geocode string
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(location.text!) { (placemarks, error) in
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    self.showAlert(title: "Invalid Location", message: "Please enter a valid location.")
                    ActivityIndicator.removeSpinner(spinner: activityIndicator)
                    return
                }
                let placemark = placemarks?.first
                let lat = placemark?.location?.coordinate.latitude
                let lon = placemark?.location?.coordinate.longitude
                let addLocationView = self.storyboard?.instantiateViewController(withIdentifier: "AddLocation") as! AddLocationViewController
                addLocationView.latitude = lat
                addLocationView.longitude = lon
                addLocationView.mediaURL = self.url.text!
                addLocationView.location = self.location.text!
                ActivityIndicator.removeSpinner(spinner: activityIndicator)
                self.navigationController?.pushViewController(addLocationView, animated: true)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure UI
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        findButton.layer.cornerRadius = 5
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
