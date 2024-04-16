//
//  EngageDevViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 04/04/24.
//

import UIKit
import FirebaseDatabase
import Firebase

class EngageDevViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EngageDeviceCellDelegate {
    
    var devices: [EngageDevice] = []
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    var selectedIndex = -1
    var isCallpase = false
    var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView   .automaticDimension
        tableView.separatorStyle = .none
        
        // Initialize and configure the activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        tableView.addSubview(activityIndicator)
        
        // Center the activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        
        // Initialize and configure the loading label
        loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = .gray
        loadingLabel.text = "Loading..."
        tableView.addSubview(loadingLabel)
        
        // Center the loading label
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -50)
        ])
        fetchUserData()
    }
    
    func returnButtonTapped(cell: EngageDeviceTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        // Check if the index is within the bounds of the devices array
        guard indexPath.row < devices.count else {
            print("Index out of range")
            return
        }
        
        let device = devices[indexPath.row]
        
        // Create an alert controller
        let alertController = UIAlertController(title: "Return Device", message: "Are you sure you want to return this device?", preferredStyle: .alert)
        
        // Add return action
        let returnAction = UIAlertAction(title: "Return", style: .default) { _ in
            // Perform database operation to remove the device
            let devicesRef = Database.database().reference().child("engagedDevices").child(device.deviceID)
            devicesRef.removeValue { error, _ in
                // Update isAvailable in 'device' node to true after returning
                Database.database().reference().child("device").child(device.deviceID).child("isAvailable").setValue(true)
                
                if let error = error {
                    print("Error removing device data: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        // Add cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add actions to the alert controller
        alertController.addAction(returnAction)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        present(alertController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedIndex == indexPath.row && isCallpase == true {
            return 300
        }else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EngageDeviceTableViewCell
        
        // Check if indexPath.row is within the bounds of devices array
        guard indexPath.row < devices.count else {
            return cell // Return an empty cell if the index is out of range
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        let device = devices[indexPath.row]
        cell.txtDeviceName?.text = device.deviceName
        cell.txtDeviceId?.text = "Device ID : \(device.deviceID)"
        cell.txtEmpNo?.text = "Employee Number : \(device.empNo)"
        cell.txtEmpName?.text = "Employee Name : \(device.empName)"
        
        cell.cellView.layer.cornerRadius =  30
        cell.selectionStyle = .none
        tableView.separatorStyle = .none
        
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        
        if indexPath.row == selectedIndex {
            cell.downArrow.image = isCallpase ? UIImage(named: "up") : UIImage(named: "down")
        } else {
            cell.downArrow.image = UIImage(named: "down") // Default arrow icon
        }
        
        // Check if imageURL is available
        if let imageURLString = device.imageURL, let imageURL = URL(string: imageURLString) {
            if let cachedImage = imageCache.object(forKey: imageURLString as NSString) {
                cell.deviceImage.image = cachedImage // Use cached image if available
                self.activityIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
            } else {
                // Load image asynchronously and cache it
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                        self.imageCache.setObject(image, forKey: imageURLString as NSString)
                        DispatchQueue.main.async {
                            cell.deviceImage.image = image
                            self.loadingLabel.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if devices.isEmpty {
            // Show "No device found" message
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            messageLabel.text = "No device found"
            messageLabel.textColor = .black
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .none
        } else {
            // Remove the message label and show the devices
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        
        return devices.count    }
    
    
    
    func fetchUserData() {
        let devicesRef = Database.database().reference().child("engagedDevices")
        
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        tableView.separatorStyle = .none
        
        
        devicesRef.observe(.value) { snapshot in
            self.devices.removeAll() // Clear previous data
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let deviceDict = childSnapshot.value as? [String: Any] {
                    let id = childSnapshot.key
                    let deviceName = deviceDict["deviceName"] as? String ?? ""
                    let empName = deviceDict["empName"] as? String ?? ""
                    let empNo = deviceDict["empNo"] as? String ?? ""
                    let imageURL = deviceDict["imageURL"] as? String
                    let isAvailable = deviceDict["isAvailable"] as? Bool ?? true
                    
                    let device = EngageDevice(deviceID: id, deviceName: deviceName, empName: empName, empNo: empNo, imageURL: imageURL, isAvailable: isAvailable)
                    self.devices.append(device)
                    
                }
            }
            
            DispatchQueue.main.async {
                self.devices = self.devices // Assign new data to devices array
                self.tableView.reloadData() // Reload table view on the main thread
                self.activityIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
                self.tableView.separatorStyle = .singleLine
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if selectedIndex == indexPath.row {
            if isCallpase {
                isCallpase = false
                selectedIndex = -1
            } else {
                isCallpase = true
            }
        } else {
            // Collapse the previously expanded cell if any
            if selectedIndex != -1 {
                let previousIndexPath = IndexPath(row: selectedIndex, section: 0)
                isCallpase = false
                selectedIndex = -1
                tableView.reloadRows(at: [previousIndexPath], with: .automatic)
            }
            // Expand the selected cell
            isCallpase = true
            selectedIndex = indexPath.row
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
}

//create model struct
struct EngageDevice {
    var deviceID: String
    var deviceName : String
    var empName : String
    var empNo : String
    var imageURL : String?
    var isAvailable: Bool
}
