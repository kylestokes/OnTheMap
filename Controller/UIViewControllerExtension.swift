//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 5/10/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: Configure alert
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
