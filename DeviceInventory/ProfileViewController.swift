//
//  ProfileViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 21/03/24.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    var databaseRef: DatabaseReference!
    
    
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    @IBOutlet weak var curveView: UIView!
    
    @IBOutlet weak var EditProfileButton: UIButton!
    
    @IBOutlet weak var changePass: UIButton!
    
    @IBOutlet weak var logOut: UIButton!
    
    @IBOutlet weak var lblWelcome: UILabel!
    
    @IBOutlet weak var circularImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularImage.layer.cornerRadius = circularImage.frame.width / 2
        circularImage.clipsToBounds = true
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecodnizer:)))
        circularImage.addGestureRecognizer(tapGesture)
        circularImage.isUserInteractionEnabled = true
        
        // Apply rounded corners to the left and right corners
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
        logOut.tintColor = UIColor.red // Change color as needed
        logOut.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -15)
        
        databaseRef = Database.database().reference()
        fetchUserName()
        
        progressView.isHidden = true

        loadProfileImageFromFirebase()
     
    }
    
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

            // Observe changes to the user's data
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
    
    
    func loadProfileImage(withURL imageURL: URL) {
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.circularImage.image = image
                    }
                }
            }.resume()
        
        
      

        }
    
    
    @objc func imageTapped(tapGestureRecodnizer: UITapGestureRecognizer){
        openGallery()
        print("Tapped")
        
    }
    
    @IBAction func editInformationClick(_ sender: UIButton) {
        
        let ProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        ProfileVC.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(ProfileVC, animated: true)

   
    }
    
//
//    @IBAction func uploadImageClick(_ sender: UIButton) {
//
//        self.uploadImage(self.circularImage.image!){url in
//            self.saveImage(profileURL: url!){success in
//                if success != nil {
//                    print("Got it")
//                }
//            }
//        }
//    }
    
    
    @IBAction func changePasswordClick(_ sender: UIButton) {
        
        let ProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordController") as! ForgetPasswordController
        self.navigationController?.pushViewController(ProfileVC, animated: true)
        
        
    }
    
    
    
    @IBAction func logoutClick(_ sender: Any) {
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
extension ProfileViewController: UINavigationBarDelegate, UIImagePickerControllerDelegate{
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
}
extension ProfileViewController{
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

