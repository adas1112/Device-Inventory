//
//  Protocols.swift
//  DeviceInventory
//
//  Created by Bilal on 20/05/25.
//

import Foundation

protocol DeviceAvailabilityDelegate: AnyObject {
    func updateAvailability(isAvailable: Bool, forRowAt indexPath: IndexPath)
    func didTapCheckBox(at indexPath: IndexPath, isChecked: Bool)
}

protocol EngageDeviceCellDelegate: AnyObject {
    func returnButtonTapped(cell: EngageDeviceTableViewCell)
}

