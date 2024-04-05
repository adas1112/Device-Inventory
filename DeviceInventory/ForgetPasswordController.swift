//
//  ForgetPasswordController.swift
//  DeviceInventory
//
//  Created by Bilal on 12/03/24.
//

import UIKit
import Firebase

class ForgetPasswordController: UIViewController {
    
    var isButtonEnabled = true
    @IBOutlet weak var backTapped: UIImageView!
    @IBOutlet weak var curveView: UIView!
    
    @IBOutlet weak var txtEmail: UITextField!
    {
        didSet {
            txtEmail.tintColor = UIColor.gray
            txtEmail.setIcon(UIImage(imageLiteralResourceName: "email1"))
        }
    }
    
    @IBOutlet weak var txtEmpNo: UITextField!
    {
        didSet {
            txtEmpNo.tintColor = UIColor.gray
            txtEmpNo.setIcon(UIImage(imageLiteralResourceName: "employee1"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmail.delegate = self
        txtEmpNo.delegate = self
        
        // Apply rounded corners to the left and right corners
        let cornerRadius: CGFloat = 60
        let maskPath = UIBezierPath(
            roundedRect: curveView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        curveView.layer.mask = maskLayer
        
        hideKeyboard()
        
        //Back Icon Navigation Using Tap Gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        backTapped.isUserInteractionEnabled = true
        backTapped.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func imageViewTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.textFieldReturn(textField)
    }
    
    @IBAction func doneClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func resetButtonClick(_ sender: UIButton) {
        guard let email = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let employeeNumber = txtEmpNo.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty, !employeeNumber.isEmpty else {
            if self.isButtonEnabled {
                self.showToastAlert(message: "Enter email and emp number!")
                self.isButtonEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.isButtonEnabled = true
                }
            }
            return
        }
        
        // Verify email address format
        if !email.validateEmailAddress() {
            if self.isButtonEnabled {
                self.showToastAlert(message: "Enter valid email address")
                self.isButtonEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.isButtonEnabled = true
                }
            }
            return
        }
        
        // Check if employee number matches in the database
        checkEmployeeNumberMatch(email: email, employeeNumber: employeeNumber)
    }
    
    func checkEmployeeNumberMatch(email: String, employeeNumber: String) {
        // Assuming your Firebase Realtime Database structure has a 'users' node with employee numbers stored as a child node
        let usersRef = Database.database().reference().child("users")
        usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            if let userSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
               let userData = userSnapshot.value as? [String: Any],
               let storedEmployeeNumber = userData["empNumber"] as? String,
               storedEmployeeNumber == employeeNumber {
                // Employee number matches, send password reset email
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        self.showToastAlert(message: "Error resetting password: \(error.localizedDescription)")
                    } else {
                        if self.isButtonEnabled {
                            self.showToastAlert(message: "Reset password email sent!")
                            self.isButtonEnabled = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.isButtonEnabled = true
                            }
                        }
                        self.txtEmail.text = ""
                        self.txtEmpNo.text = ""
                    }
                }
            } else {
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Invalid email or emp number!")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
            }
        })
    }
}


