//
//  LoginViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 04/03/24.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {
    
    
    
    @IBOutlet weak var curveView: UIView!
    
    
    @IBOutlet weak var txtEmpno: UITextField!
    {
        didSet {
            txtEmpno.tintColor = UIColor.gray
            txtEmpno.setIcon(UIImage(imageLiteralResourceName: "employee1"))
        }
    }
    
    
    @IBOutlet weak var txtEmail: UITextField!{
        didSet {
            txtEmail.tintColor = UIColor.gray
            txtEmail.setIcon(UIImage(imageLiteralResourceName: "email1"))
        }
    }
    
    @IBOutlet weak var txtPassword: UITextField!
    {
        didSet {
            txtPassword.tintColor = UIColor.gray
            txtPassword.setIcon(UIImage(imageLiteralResourceName: "password1"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        textFieldBorder()
        
        
        
        
        
        
        
    }
    
    func textFieldBorder(){
        
        txtEmpno.layer.borderColor = UIColor.gray.cgColor
        txtEmpno.layer.borderWidth = 1.5
        txtEmpno.layer.cornerRadius = 25.0
        txtEmpno.clipsToBounds = true
        
        
        txtEmail.layer.borderColor = UIColor.gray.cgColor
        txtEmail.layer.borderWidth = 1.5
        txtEmail.layer.cornerRadius = 25.0
        txtEmail.clipsToBounds = true
        
        
        txtPassword.layer.borderColor = UIColor.gray.cgColor
        txtPassword.layer.borderWidth = 1.5
        txtPassword.layer.cornerRadius = 25.0
        txtPassword.clipsToBounds = true
        
    }
    
    
    @IBAction func buttonLoginClick(_ sender: UIButton) {
        
        
        //Validations of textFields
        if let email = txtEmail.text ,let password = txtPassword.text, let employee = txtEmpno.text{
            if employee == ""{
                alertView(title: "Alert", message: "Please Enter Employee no", alertStyle: .alert, actionTitles: ["okay"], actionStyles: [.default], actions: [{_ in
                }])
                
            }else if !email.validateEmailAddress(){
                alertView(title: "Alert", message: "Please Enter Valid Email", alertStyle: .alert, actionTitles: ["okay"], actionStyles: [.default], actions: [{_ in
                }])
                
            }else if !password.validatePassword(){
                alertView(title: "Alert", message: "Please Enter Valid Password", alertStyle: .alert, actionTitles: ["okay"], actionStyles: [.default], actions: [{_ in
                }])
                
            }
        }
        
        
        guard let empNumber = txtEmpno.text,
                      let email = txtEmail.text,
                      let password = txtPassword.text else {
                    // Handle missing input
                    return
                }
        
        
        // Reference to the users node in the Realtime Database
             let usersRef = Database.database().reference().child("users")

             // Query to check if the provided credentials exist in the database
             let query = usersRef.queryOrdered(byChild: "empNumber").queryEqual(toValue: empNumber)

             query.observeSingleEvent(of: .value) { snapshot in
                 guard let userSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                       let user = userSnapshot.value as? [String: Any],
                       let storedEmail = user["email"] as? String,
                       let storedPassword = user["password"] as? String else {
                     // User not found or unable to retrieve user data
                     self.alertView(title: "Alert", message: "Employee No not found!", alertStyle: .alert, actionTitles: ["Enter"], actionStyles: [.default], actions: [{_ in
                     }])

                     return
                 }

                 // Verify the entered password against the stored hashed password
                 if email == storedEmail && self.verifyPassword(password, hashedPassword: storedPassword) {
                     // Passwords match, login successful
                     self.alertView(title: "Successful!!", message: "Login Successfully!!", alertStyle: .alert, actionTitles: ["Next"], actionStyles: [.default], actions: [{_ in
                         
                         let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                         self.navigationController?.pushViewController(LoginVC, animated: true)
                     }])
                     self.txtEmpno.text = ""
                     self.txtEmail.text = ""
                     self.txtPassword.text = ""
                     
                 } else {
                     // Passwords don't match
                     self.alertView(title: "Alert", message: "Enter correct email or password", alertStyle: .alert, actionTitles: ["Enter"], actionStyles: [.default], actions: [{_ in
                     }])

                 
                 }
             }
         }

         func verifyPassword(_ password: String, hashedPassword: String) -> Bool {
          
             return password == hashedPassword
         }
        
        
    
    
    @IBAction func buttonSignUpNavigation(_ sender: UIButton) {
        
        //navigation on signup screeen
        let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(LoginVC, animated: true)
        
    }
    
    
}

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 10, y: 5, width: 30, height: 30))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 20, y: 0, width: 45, height: 45))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}




