
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DeviceAvailabilityDelegate{
    func didTapCheckBox(at indexPath: IndexPath, isChecked: Bool) {
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    
    
    @IBOutlet weak var seachData: UITextField!{
        didSet {
            seachData.tintColor = UIColor.gray
            seachData.setIcon(UIImage(imageLiteralResourceName: "search"))
        }
    }
    
    
    weak var delegate: DeviceAvailabilityDelegate?
    
    var devices: [Devices] = [] // Array to store device data
    
    var selectedIndex = -1
    var isCallpase = false
    
    var imageCache: NSCache<NSString, UIImage> = NSCache()
    var checkboxStates: [IndexPath: Bool] = [:] // Store checkbox states
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let placeholderText = "Search devices"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18), // Set the desired font size here
            .foregroundColor: UIColor.gray // Optionally, set the placeholder text color
        ]
        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        // Set the attributed placeholder text to the text field
        seachData.attributedPlaceholder = attributedPlaceholder
        
        
        seachData.layer.borderColor = UIColor.gray.cgColor
        seachData.layer.borderWidth = 1.5
        seachData.layer.cornerRadius = 20.0
        seachData.clipsToBounds = true
        
        tableView.estimatedRowHeight = 550
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
              tapGesture.cancelsTouchesInView = false // Allow tableView to handle taps
              view.addGestureRecognizer(tapGesture)
        seachData.delegate = self

        
    }
    // Handle tap gesture to dismiss keyboard
      @objc func dismissKeyboard() {
          view.endEditing(true)
      }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Hide keyboard
            return true
        }
  
    
    
    @IBAction func searchHandler(_ sender: UITextField) {
        if let searchText = sender.text {
            if searchText.isEmpty {
                fetchUserData()
            } else {
                devices = devices.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedIndex == indexPath.row && isCallpase == true {
            return 550
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
        
        cell.previousState = UserDefaults.standard.bool(forKey: "CheckboxState_\(indexPath.row)")
        
        let device = devices[indexPath.row]
        cell.txtDeviceName.text = device.name
        cell.txtDescription.text = device.description
        cell.txtConfiguration.text = "Description :- \(device.configuration)"
        cell.txtVersion.text = "Version :- \(device.version)"
        cell.txtStatus.text = device.isAvailable ? "Available" : "Unavailable"
        cell.txtStatus.textColor = device.isAvailable ? UIColor.systemGreen : UIColor.red
        
        
        
        if let isChecked = UserDefaults.standard.value(forKey: "CheckboxState_\(indexPath.row)") as? Bool {
            if isChecked {
                if let image = UIImage(named: "select") {
                    cell.checkImage.image = image
                } else {
                    print("Failed to load 'select' image")
                }
            } else {
                if let image = UIImage(named: "unselect") {
                    cell.checkImage.image = image
                } else {
                    print("Failed to load 'unselect' image")
                }
            }
        } else {
            
        }
        
        // Set availability button background image based on device's availability
        let buttonImageName = device.isAvailable ? "select" : "unselect"
        cell.checkImage.image = UIImage(named: buttonImageName)
        
        // Handle button tap
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(self, action: #selector(availabilityButtonTapped(_:)), for: .touchUpInside)
        
        
        
        cell.cellView.layer.cornerRadius =  30
        cell.selectionStyle = .none;
        tableView.separatorStyle = .none
        
        
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        
        if indexPath.row == selectedIndex {
            cell.downArrow.image = isCallpase ? UIImage(named: "up") : UIImage(named: "down")
        } else {
            cell.downArrow.image = UIImage(named: "down") // Default arrow icon
        }
        
        
        
//        // Check if the device is unavailable to disable the checkbox
//         if !device.isAvailable {
//             cell.checkBox.isEnabled = false
//             cell.checkImage.image = UIImage(named: "unselect")
//         } else {
//             cell.checkBox.isEnabled = false
//             cell.checkImage.image = UIImage(named: "select")
//         }

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
    
    @objc func availabilityButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let device = devices[sender.tag]
        let isAvailable = !device.isAvailable // Toggle availability
        
        // Update device's availability in Firebase and locally
        delegate?.updateAvailability(isAvailable: isAvailable, forRowAt: indexPath)
        
        
        
        // Update device's availability status and UserDefaults
        devices[sender.tag].isAvailable = isAvailable
        UserDefaults.standard.set(isAvailable, forKey: "CheckboxState_\(sender.tag)")
    }
    
    
    
    func updateAvailability(isAvailable: Bool, forRowAt indexPath: IndexPath) {
        
        
        var device = devices[indexPath.row]
        device.isAvailable = isAvailable
        UserDefaults.standard.set(isAvailable, forKey: "CheckboxState_\(indexPath.row)")
        
        let deviceRef = Database.database().reference().child("device").child(device.id)
        deviceRef.updateChildValues(["isAvailable": isAvailable]) { error, _ in
            if let error = error {
                print("Error updating isAvailable in database: \(error.localizedDescription)")
            } else {
                print("isAvailable updated successfully in database")
            }
        }
        
        
        
        
        checkboxStates[indexPath] = isAvailable
        if !isAvailable {
            // Disable checkbox if the device is unavailable
            guard let cell = tableView.cellForRow(at: indexPath) as? DevicelistTableViewCell else {
                return
            }
            cell.checkBox.isEnabled = false
            cell.checkImage.image = UIImage(named: "unselect")
        } else {
            // Enable checkbox if the device is available
            guard let cell = tableView.cellForRow(at: indexPath) as? DevicelistTableViewCell else {
                return
            }
            cell.checkBox.isEnabled = true
            cell.checkImage.image = UIImage(named: "unselect")
        }
        
        if !isAvailable {
            guard let currentUser = Auth.auth().currentUser else {
                // Handle if user is not logged in
                return
            }
            
            let userID = currentUser.uid
            let usersRef = Database.database().reference().child("users").child(userID)
            usersRef.observeSingleEvent(of: .value) { snapshot, _ in // Added placeholder for the second argument
                if let userData = snapshot.value as? [String: Any] {
                    let userName = userData["name"] as? String ?? ""
                    let userEmpNo = userData["empNumber"] as? String ?? ""
                    
                    self.storeUncheckedDevice(device, userName: userName, userEmpNo: userEmpNo, imageURL: device.imageURL ?? "")
                }
            }
        }
        tableView.reloadData()
        
    }
    
    func storeUncheckedDevice(_ device: Devices, userName: String, userEmpNo: String, imageURL: String) {
        let engagedDevicesRef = Database.database().reference().child("engagedDevices")
        engagedDevicesRef.child(device.id).setValue([
            "deviceName": device.name,
            "deviceID": device.id,
            "imageURL": device.imageURL,
            "empNo": userEmpNo,
            "empName": userName
        ])
    }
    
    func updateCheckboxStates() {
        for (index, device) in devices.enumerated() {
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DevicelistTableViewCell else {
                continue
            }
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

