//
//  EngageDeviceTableViewCell.swift
//  DeviceInventory
//
//  Created by Bilal on 04/04/24.
//

import UIKit

class EngageDeviceTableViewCell: UITableViewCell {
    
    //MARK: - Outlets

    @IBOutlet weak var txtDeviceName: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var txtDeviceId: UILabel!
    @IBOutlet weak var txtEmpNo: UILabel!
    @IBOutlet weak var txtEmpName: UILabel!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var returmButton: UIButton!
    @IBOutlet weak var downArrow: UIImageView!

    //MARK: - Variabels

    weak var delegate: EngageDeviceCellDelegate?
    var indexPath: IndexPath?
    var previousState: Bool?

    override func awakeFromNib() {
        super.awakeFromNib()
        returmButton.layer.cornerRadius = 20
        returmButton.clipsToBounds = true
    }
    
    //MARK: - Button Actions

    @IBAction func returnClick(_ sender: UIButton) {
        delegate?.returnButtonTapped(cell: self)
    }
}
