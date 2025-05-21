//
//  ProfileViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 21/03/24.
//

import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    @IBOutlet weak var curveView: UIView!
    @IBOutlet weak var EditProfileButton: UIButton!
    @IBOutlet weak var changePass: UIButton!
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var circularImage: UIImageView!
    
    //MARK: - Variabels
    
    var databaseRef: DatabaseReference!
    var cameraAccessDeniedOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        progressView.isHidden = true
        
        fetchUserName()
        loadProfileImageFromFirebase()
        setupUI()
    }
    
    //MARK: - UI Setup
    
    func setupUI(){
        circularImage.layer.cornerRadius = circularImage.frame.width / 2
        circularImage.clipsToBounds = true
        
        cameraIcon.layer.cornerRadius = cameraIcon.frame.width / 2
        cameraIcon.clipsToBounds = true
        cameraIcon.image = UIImage(named: "camera") // Replace "camera_icon" with your actual image name
        cameraIcon.layer.opacity = 0.7 // Adjust the opacity as needed
        
        let screenWidth = UIScreen.main.bounds.width
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecodnizer:)))
        circularImage.addGestureRecognizer(tapGesture)
        circularImage.isUserInteractionEnabled = true
        
        let cornerRadius: CGFloat = 40
        let maskPath = UIBezierPath(
            roundedRect: curveView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        curveView.layer.mask = maskLayer
        
        EditProfileButton.setImage(UIImage(named: "edit"), for: .normal)
        EditProfileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -15)
        
        changePass.setImage(UIImage(named: "key"), for: .normal)
        changePass.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -15)
        
        logOut.setImage(UIImage(named: "logout"), for: .normal)
        logOut.tintColor = UIColor.red
        logOut.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -15)
        
    }
    
    //MARK: - Fetch Data From Firebase
    
    func loadProfileImageFromFirebase() {
        progressView.isHidden = false
        progressView.startAnimating()
        
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let storageRef = Storage.storage().reference().child("user images").child(userID)
            
            // Download profile image from Firebase Storage
            storageRef.downloadURL { (url, error) in
                if let imageURL = url {
                    // Download image data
                    URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                        if let imageData = data, let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self.circularImage.image = image
                                self.progressView.stopAnimating()
                                self.progressView.isHidden = true // Hide activity indicator
                            }
                        }
                    }.resume()
                } else {
                    print("Error fetching profile image URL:", error?.localizedDescription ?? "")
                    DispatchQueue.main.async {
                        self.progressView.stopAnimating()
                        self.progressView.isHidden = true // Hide activity indicator
                        
                    }
                }
            }
        }
    }
    
    func fetchUserName() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let usersRef = databaseRef.child("users").child(userID)
            
            usersRef.observe(.value) { snapshot in
                if let userData = snapshot.value as? [String: Any],
                   let userName = userData["name"] as? String {
                    DispatchQueue.main.async {
                        self.lblWelcome.text = "Welcome \(userName)"
                    }
                }
            }
        }
    }
    
    //MARK: - Button and Image Tapped Actions
    
    @objc func imageTapped(tapGestureRecodnizer: UITapGestureRecognizer){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Camera action
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.openCamera()
        }
        
        // Photo Library action
        let photoLibraryAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            self.openGallery()
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the action sheet
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cancelAction)
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func editInformationClick(_ sender: UIButton) {
        let ProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(ProfileVC, animated: true)
    }
    
    @IBAction func changePasswordClick(_ sender: UIButton) {
        let ProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordController") as! ForgetPasswordController
        self.navigationController?.pushViewController(ProfileVC, animated: true)
    }
    
    @IBAction func logoutClick(_ sender: Any) {
        // Create an alert controller
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        // Add actions to the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            // Perform logout action
            self.performLogout()
        }
        
        // Add actions to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
        
    }
    
    func performLogout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.synchronize()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

//MARK: - Extension

extension ProfileViewController: UINavigationBarDelegate, UIImagePickerControllerDelegate{
    //MARK: - Manage Camera and Permissions
    
    func openCamera() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .authorized:
            showImagePicker()
        case .notDetermined:
            // Request camera access
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.showImagePicker()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showPermissionPrompt()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionPrompt()
        @unknown default:
            showPermissionPrompt()
        }
    }
    
    func showPermissionPrompt() {
        let alert = UIAlertController(title: "Camera Access Denied", message: "To enable camera access, please go to Settings > Privacy > Camera and enable access for this app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Image Picker and Manage Gallery
    
    func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            showToastAlert(message: "Camera is not available")
        }
    }
    
    func openGallery(){
        if  UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            present(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.editedImage] as? UIImage {
            circularImage.image = img
            uploadImage(img) { url in
                if let url = url {
                    self.saveImage(profileURL: url) { success in
                        if success {
                            print("Image uploaded and saved successfully")
                        } else {
                            print("Failed to save image URL")
                        }
                    }
                } else {
                    print("Failed to upload image")
                }
            }
        }
        picker.dismiss(animated: true)
    }
    
    //MARK: - Upload And Save Image On Firebase
    
    func uploadImage(_ image:UIImage, completion: @escaping ((_ url: URL?) -> ())){
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let storageRef = Storage.storage().reference().child("user images").child(userID)
            let imgData = circularImage.image?.jpegData(compressionQuality: 0.75)
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            storageRef.putData(imgData!,metadata: metaData){ (metadata, error) in
                if error == nil{
                    //                self.showToastAlert(message: "Successfully Uploaded!!")
                    storageRef.downloadURL(completion: {(url,error) in
                        completion(url!)
                    })
                }
                else{
                    print("Error on saveimage")
                    completion(nil)
                }
            }
        }
    }
    
    func saveImage(profileURL: URL, completion: @escaping ((_ success: Bool) -> Void)) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let usersRef = Database.database().reference().child("users").child(userID)
            
            // Update the imageURL field in the user's data
            usersRef.updateChildValues(["imageURL": profileURL.absoluteString]) { (error, ref) in
                if let error = error {
                    print("Error updating imageURL:", error.localizedDescription)
                    completion(false) // Notify the caller that the operation failed
                } else {
                    print("ImageURL updated successfully")
                    completion(true) // Notify the caller that the operation succeeded
                }
            }
        } else {
            completion(false) // Notify the caller that the operation failed
        }
    }
}
