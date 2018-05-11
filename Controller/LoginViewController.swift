//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 4/17/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update UI
        login.layer.cornerRadius = 5
    }
    
    @IBAction func loginUser(_ sender: UIButton) {
        if (email.text?.isEmpty)! || (password.text?.isEmpty)! {
            self.showAlert(title: "Uhh...", message: "Please fill in both email and password to login.")
        } else {
            let activityIndicator = ActivityIndicator.displaySpinner(onView: self.view)
            UdacityClient.sharedInstance().loginUdacity(email.text!, password.text!, completionHandlerLogin: { (error) in
                if let error = error {
                    print(error)
                    if error.localizedDescription.range(of: "offline") != nil {
                        self.showAlert(title: "🤨", message: "The Internet connection appears to be offline")
                    } else {
                        self.showAlert(title: "🤨", message: "Incorrect email or password")
                    }
                } else {
                    // Sets logged in user data
                    self.getUserAccountData()
                    // Presents next view
                    self.completeLogin()
                }
                ActivityIndicator.removeSpinner(spinner: activityIndicator)
            })
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            let safariView = SFSafariViewController(url: url)
            self.present(safariView, animated: true, completion: nil)
        }
    }
    
    private func getUserAccountData() {
        UdacityClient.sharedInstance().getCurrentStudentData(completionHandlerLocation: { (studentLocation, error) in
            if let error = error  {
                print(error)
                self.showAlert(title: "🤨", message: "Unable to get user data")
            }
        })
    }
    
    private func completeLogin() {
        DispatchQueue.main.async {
            let mapTableView = self.storyboard?.instantiateViewController(withIdentifier: "MapTableView")
            self.present(mapTableView!, animated: true, completion: nil)
        }
    }
}

