//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 4/29/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import SafariServices

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var studentLocations = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIBarButtonItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
    }
    
    func updateTable() {
        studentLocations = Shared.sharedInstance.studentLocations
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
        cell.pinImage.image = UIImage(named: "icon_pin")
        
        var firstName = ""
        var lastName = ""
        var url = ""
        
        if let fName = studentLocations[indexPath.row].firstName {
            firstName = fName
        }
        
        if let lName = studentLocations[indexPath.row].lastName {
            lastName = lName
        }
        
        if let mediaURL = studentLocations[indexPath.row].mediaURL {
            url = mediaURL
        }
        
        cell.name.text = "\(firstName) \(lastName)"
        cell.url.text = url
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let url = studentLocations[indexPath.row].mediaURL else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if url.contains("http") {
            if let url = URL(string: url) {
                let safariView = SFSafariViewController(url: url)
                self.present(safariView, animated: true, completion: nil)
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension TableViewController {
    @objc func refreshData() {
        let activityIndicator = ActivityIndicator.displaySpinner(onView: self.view)
        ParseClient.sharedInstance().getStudentLocations(completionHandlerLocations: { (studentLocations, error) in
            if let error = error {
                print(error)
                self.showAlert(title: "🤨", message: "Unable to get student locations")
            } else {
                self.updateTable()
            }
            ActivityIndicator.removeSpinner(spinner: activityIndicator)
        })
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
