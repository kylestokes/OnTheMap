//
//  StudentCell.swift
//  OnTheMap
//
//  Created by Kyle Stokes on 4/17/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit

class StudentCell: UITableViewCell {
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var url: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
