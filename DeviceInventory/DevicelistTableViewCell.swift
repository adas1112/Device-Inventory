//
//  DevicelistTableViewCell.swift
//  DeviceInventory
//
//  Created by Bilal on 01/04/24.
//

import UIKit


protocol DeviceAvailabilityDelegate: AnyObject {
    func updateAvailability(isAvailable: Bool, forRowAt indexPath: IndexPath)
    func didTapCheckBox(at indexPath: IndexPath, isChecked: Bool)
}

class DevicelistTableViewCell: UITableViewCell {
    
    var checkboxStates: [IndexPath: Bool] = [:]
    @IBOutlet weak var txtDeviceName: UILabel!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var txtConfiguration: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var txtVersion: UILabel!
    @IBOutlet weak var txtAvailable: UILabel!
    var flag = false
    var previousState: Bool?

    @IBOutlet weak var checkImage: UIImageView!
    var isFirstClick = true // Track the initial click state
    
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    @IBOutlet weak var checkBox: UIButton!
    
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    weak var delegate: DeviceAvailabilityDelegate?
    var indexPath: IndexPath?
    
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        
        txtDescription.numberOfLines = 0 // Set to 0 for multiline support
        txtDescription.lineBreakMode = .byWordWrapping
        checkBox.isEnabled = previousState ?? true

        
        submitButton.layer.cornerRadius = 20 // Adjust the corner radius as needed
        submitButton.clipsToBounds = true
        
        // Set initial state for status label
        txtStatus.isHidden = false // Make txtStatus permanently visible
        
        
    }
    
    @IBAction func checkBoxClick(_ sender: UIButton) {
        

        flag = !flag // Toggle the flag variable instead of using toggle()
            if flag {
                checkImage.image = UIImage(named: "select")
//                txtStatus.text = "Available"
//                txtStatus.textColor = .systemGreen
            } else {
                checkImage.image = UIImage(named: "unselect")
//                txtStatus.text = "Unavailable"
//                txtStatus.textColor = .red
            }
            
        UserDefaults.standard.set(flag, forKey: "CheckboxState_\(indexPath?.row ?? 0)")
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        
//        if flag {
//             txtStatus.text = "Available"
//             txtStatus.textColor = .systemGreen
//         } else {
//             txtStatus.text = "Unavailable"
//             txtStatus.textColor = .red
//         }
//        
        if flag {
                  txtStatus.text = "Available"
                  txtStatus.textColor = .systemGreen
                  delegate?.updateAvailability(isAvailable: true, forRowAt: indexPath!)
              } else {
                  txtStatus.text = "Unavailable"
                  txtStatus.textColor = .red
                  delegate?.updateAvailability(isAvailable: false, forRowAt: indexPath!)
                  
              }

              // Update the previous checkbox state
              previousState = flag
        UserDefaults.standard.set(flag, forKey: "CheckboxState_\(indexPath!.row)")
//        guard let indexPath = indexPath else { return }
//
//           // Get the current checkbox state from UserDefaults
//           let isChecked = UserDefaults.standard.bool(forKey: "CheckboxState_\(indexPath.row)")
//
//           // Update availability status in Firebase only if the checkbox state changed
//           if isChecked == flag {
//               delegate?.updateAvailability(isAvailable: flag, forRowAt: indexPath)
//
//           }
//        UserDefaults.standard.set(flag, forKey: "CheckboxState_\(indexPath.row)")

    }
    
}


