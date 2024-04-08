//
//  EngageDeviceTableViewCell.swift
//  DeviceInventory
//
//  Created by Bilal on 04/04/24.
//

import UIKit

class EngageDeviceTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var txtDeviceName: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var txtDeviceId: UILabel!
    @IBOutlet weak var txtEmpNo: UILabel!
    @IBOutlet weak var txtEmpName: UILabel!
    var indexPath: IndexPath?
    var previousState: Bool?
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var returmButton: UIButton!
    @IBOutlet weak var downArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        returmButton.layer.cornerRadius = 20 // Adjust the corner radius as needed
        returmButton.clipsToBounds = true
        

    }
    
    
    @IBAction func returnClick(_ sender: UIButton) {
        
        
    }
    


}
