//
//  EngageDeviceTableViewCell.swift
//  DeviceInventory
//
//  Created by Bilal on 04/04/24.
//

import UIKit

class EngageDeviceTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var txtDeviceName: UILabel!
    
    @IBOutlet weak var txtDeviceId: UILabel!
    @IBOutlet weak var txtEmpNo: UILabel!
    @IBOutlet weak var txtEmpName: UILabel!
    
    @IBOutlet weak var returmButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func returnClick(_ sender: UIButton) {
        
        
    }
    


}
