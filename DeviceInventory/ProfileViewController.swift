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
    
    @IBOutlet weak var curveView: UIView!
    
    @IBOutlet weak var EditProfileButton: UIButton!
    
    @IBOutlet weak var changePass: UIButton!
    
    @IBOutlet weak var logOut: UIButton!
    
    
    @IBOutlet weak var circularImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    
    
    
    
    
    @objc func imageTapped(tapGestureRecodnizer: UITapGestureRecognizer){
        openGallery()
        print("Tapped")
        
    }
    
    @IBAction func editInformationClick(_ sender: UIButton) {
   
    }
    
    
    @IBAction func uploadImageClick(_ sender: UIButton) {
        
        self.uploadImage(self.circularImage.image!){url in
            self.saveImage(profileURL: url!){success in
                if success != nil {
                    print("Got it")
                }
            }
        }
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
        if let img = info[.originalImage] as? UIImage{
            circularImage.image = img
        }
        dismiss(animated: true)
    }
}
extension ProfileViewController{
    func uploadImage(_ image:UIImage, completion: @escaping ((_ url: URL?) -> ())){
        let storageRef = Storage.storage().reference().child("Profileimg.jpg")
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
    
    func saveImage(profileURL:URL, completion: @escaping ((_ url: URL?) -> ())){
        let dict = ["profileUrl":profileURL.absoluteString] as! [String: Any]
        self.databaseRef.child("Urls").childByAutoId().setValue(dict)
    }
}
