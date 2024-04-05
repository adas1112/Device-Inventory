//
//  DevicelistTableViewCell.swift
//  DeviceInventory
//
//  Created by Bilal on 01/04/24.
//

import UIKit
import BEMCheckBox

protocol DeviceAvailabilityDelegate: AnyObject {
    func updateAvailability(isAvailable: Bool, forRowAt indexPath: IndexPath)
}

class DevicelistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var txtDeviceName: UILabel!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var txtConfiguration: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var txtVersion: UILabel!
    @IBOutlet weak var txtAvailable: UILabel!
    
    
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var yesCheckBox: BEMCheckBox!
    
    
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    weak var delegate: DeviceAvailabilityDelegate?
    var indexPath: IndexPath?
    var previousState: Bool?

    
    override  func awakeFromNib() {
        super.awakeFromNib()
        
        txtDescription.numberOfLines = 0 // Set to 0 for multiline support
        txtDescription.lineBreakMode = .byWordWrapping
        
        
        submitButton.layer.cornerRadius = 20 // Adjust the corner radius as needed
        submitButton.clipsToBounds = true
        
        yesCheckBox.delegate = self
        // Set initial state for status label
        txtStatus.isHidden = false // Make txtStatus permanently visible
        
    }
    
    
    @IBAction func submitClick(_ sender: UIButton) {
        guard let indexPath = indexPath, let previousState = previousState else { return }
                  
             // Check if the checkbox state has changed since last tap
             if previousState == yesCheckBox.on {
                 delegate?.updateAvailability(isAvailable: yesCheckBox.on, forRowAt: indexPath)
                 UserDefaults.standard.set(yesCheckBox.on, forKey: "CheckboxState_\(indexPath.row)")
                 
                
             }
    }
    
    
}
    

extension DevicelistTableViewCell: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        if let indexPath = indexPath {
                    previousState = checkBox.on // Update previousState when checkbox is tapped

            txtStatus.text = checkBox.on ? "Available" : "Unavailable"
                     txtStatus.textColor = checkBox.on ? UIColor.green : UIColor.red
            
            
                 
                    
                }
    }
 
}

