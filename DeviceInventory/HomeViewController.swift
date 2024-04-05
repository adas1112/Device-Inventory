
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DeviceAvailabilityDelegate{
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    
    var devices: [Devices] = [] // Array to store device data
    
    var selectedIndex = -1
    var isCallpase = false
    
    var imageCache: NSCache<NSString, UIImage> = NSCache()
    var checkboxStates: [IndexPath: Bool] = [:] // Store checkbox states
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableView   .automaticDimension
        
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
        
        tableView.separatorStyle = .none
        fetchUserData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedIndex == indexPath.row && isCallpase == true {
            return 600
        }else {
            return 120
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DevicelistTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        let device = devices[indexPath.row]
        cell.txtDeviceName.text = device.name
        cell.txtDescription.text = device.description
        cell.txtConfiguration.text = "Description :- \(device.configuration)"
        cell.txtVersion.text = "Version :- \(device.version)"
        cell.txtStatus.text = device.isAvailable ? "Available" : "Unavailable"
        cell.txtStatus.textColor = device.isAvailable ? UIColor.green : UIColor.red


        
        cell.yesCheckBox.setOn(device.isAvailable, animated: false)

        cell.cellView.layer.cornerRadius =  30
        cell.selectionStyle = .none;
        tableView.separatorStyle = .none
        
        // Set checkbox state based on UserDefaults
        if let isChecked = UserDefaults.standard.value(forKey: "CheckboxState_\(indexPath.row)") as? Bool {
            cell.yesCheckBox.setOn(isChecked, animated: false)
            checkboxStates[indexPath] = isChecked
        } else {
            cell.yesCheckBox.setOn(false, animated: false)
            checkboxStates[indexPath] = false
        }

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
    
    func storeUncheckedDevice(_ device: Devices, userName: String, userEmpNo: String) {
        let engagedDevicesRef = Database.database().reference().child("engagedDevices")
        engagedDevicesRef.child(device.id).setValue([
            "deviceName": device.name,
            "deviceID": device.id,
            "empNo": userEmpNo,
            "userName": userName
        ])
    }

    func updateAvailability(isAvailable: Bool, forRowAt indexPath: IndexPath) {
        

        let device = devices[indexPath.row]
        let deviceId = device.id
        let databaseRef = Database.database().reference().child("device").child(deviceId)
        
        // Update isAvailable in Firebase based on checkbox state
           databaseRef.updateChildValues(["isAvailable": isAvailable]) { error, _ in
               if let error = error {
                   print("Error updating isAvailable in database: \(error.localizedDescription)")
               } else {
                   print("isAvailable updated successfully in database")
               }
           }
        
        checkboxStates[indexPath] = isAvailable


//           // Update the local data model
//           devices[indexPath.row].isAvailable = isAvailable
//
//           // Update the checkbox state in the table view cell
//           if let cell = tableView.cellForRow(at: indexPath) as? DevicelistTableViewCell {
//               cell.yesCheckBox.setOn(isAvailable, animated: true)
//           }
    }
  
    func updateCheckboxStates() {
        for (index, device) in devices.enumerated() {
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DevicelistTableViewCell else {
                continue
            }
            
            cell.yesCheckBox.setOn(device.isAvailable, animated: true)
        }
    }
 
    func fetchUserData() {
        let devicesRef = Database.database().reference().child("device")
        
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        tableView.separatorStyle = .none
        
        
        devicesRef.observe(.value) { snapshot in
            self.devices.removeAll() // Clear previous data
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let deviceDict = childSnapshot.value as? [String: Any] {
                    let id = childSnapshot.key
                    let name = deviceDict["name"] as? String ?? ""
                    let description = deviceDict["description"] as? String ?? ""
                    let configuration = deviceDict["configuration"] as? String ?? ""
                    let version = deviceDict["version"] as? String ?? ""
                    let imageURL = deviceDict["imageURL"] as? String ?? "" // Fetch imageURL
                    let isAvailable = deviceDict["isAvailable"] as? Bool ?? true
                    
                    
                    let device = Devices(id: id,name: name, configuration: configuration, description: description, version: version, imageURL: imageURL, isAvailable: isAvailable)
                    
                    self.devices.append(device)
                }
            }
            self.tableView.reloadData() // Reload table view to display fetched data
            self.activityIndicator.stopAnimating()
            self.loadingLabel.isHidden = true
            self.tableView.separatorStyle = .singleLine
            
            self.updateCheckboxStates()
            self.updateTabBarBadge()
        }
    }
    
    
    func updateTabBarBadge() {
        // Get the count of devices
        let deviceCount = devices.count
        
        // Update the tab bar item with the device count as the badge value
        if let tabBarController = self.tabBarController {
            if deviceCount > 0 {
                let desiredTabIndex = 0 // Set the index of the tab where you want to display the badge
                tabBarController.tabBar.items?[desiredTabIndex].badgeValue = "\(deviceCount)"
                // Customize badge appearance
                if let tabBarItems = tabBarController.tabBar.items, tabBarItems.count > desiredTabIndex {
                    tabBarItems[desiredTabIndex].badgeColor = .red
                    tabBarItems[desiredTabIndex].setBadgeTextAttributes([.foregroundColor: UIColor.white], for: .normal)
                }
            } else {
                let desiredTabIndex = 0 // Set the index of the tab where you want to hide the badge
                tabBarController.tabBar.items?[desiredTabIndex].badgeValue = nil // Hide badge if count is 0
            }
        }
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if selectedIndex == indexPath.row {
            if self.isCallpase == true {
                isCallpase = false
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                isCallpase = true
                tableView.reloadRows(at: [indexPath], with: .automatic)
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
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        tableView.endUpdates()
    }
}

//create model struct
struct Devices {
    var id: String
    var name : String
    var configuration: String
    var description: String
    var version: String
    var imageURL: String?
    var isAvailable: Bool
}

