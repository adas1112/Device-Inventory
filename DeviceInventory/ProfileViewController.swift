//
//  ProfileViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 21/03/24.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    var databaseRef: DatabaseReference!
    private var handle: DatabaseHandle!
    private let userId = "-NtPrqhC-KczrTpdk2su"


    
    @IBOutlet weak var welcomeLbl: UILabel!
    
    @IBOutlet weak var curveView: UIView!
    
    @IBOutlet weak var EditProfileButton: UIButton!
    
    @IBOutlet weak var changePass: UIButton!

    @IBOutlet weak var logOut: UIButton!
    
    
    @IBOutlet weak var circularImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecodnizer:)))
        circularImage.addGestureRecognizer(tapGesture)
        
        
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
        EditProfileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -15) // Adjust as needed
        
       changePass.setImage(UIImage(named: "key"), for: .normal)
       changePass.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -15) // Adjust as needed
        
        logOut.setImage(UIImage(named: "logout"), for: .normal)
        logOut.tintColor = UIColor.red // Change color as needed
        logOut.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -15) // Adjust as needed
        
        databaseRef = Database.database().reference()


               // Fetch the "name" field value from Firebase
        databaseRef.child("users").child("userID").child("name").observeSingleEvent(of: .value) { (snapshot, error) in
            if let error = error {
                print("Error fetching data: ")
                self.welcomeLbl.text = "Error fetching name"
                return
            }

            if let name = snapshot.value as? String {
                self.welcomeLbl.text = name
            } else {
                print("Name field not found or is not a string")
                self.welcomeLbl.text = "Name not available"
            }
        }
           }
    

        
                                                                  
                                                        

    @objc func imageTapped(tapGestureRecodnizer: UITapGestureRecognizer){
            openGallery()
        
    }
    
    @IBAction func editInformationClick(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func logoutClick(_ sender: Any) {
        
        try! Auth.auth().signOut()

        if let storyboard = self.storyboard {
                    let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    self.present(vc, animated: true, completion: nil)
                }

//           (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        
    }
}
extension ProfileViewController: UINavigationBarDelegate, UIImagePickerControllerDelegate{
    func openGallery(){
        if  UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let picker = UIImagePickerController()
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
