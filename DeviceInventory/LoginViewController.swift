//
//  LoginViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 04/03/24.
//

import UIKit
import Firebase
import SwiftToast

class LoginViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
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
    
    //MARK: - Variabels
    
    var isButtonEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmpno.delegate = self
        txtEmail.delegate = self
        txtPassword.delegate = self
        
        setupUI()
    }
    
    deinit {
        // Remove keyboard event observers
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UI Setup
    
    func setupUI(){
        txtPassword.enablePasswordToggle()
        
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
        hideKeyboard()
        
        // Add observers for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    //MARK: - Manage Keyboard Appearance
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    //MARK: - Textfield Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.textFieldReturn(textField)
    }
    
    //MARK: - Button ACtions
    
    @IBAction func forgetPasswordClick(_ sender: UIButton) {
        let LoginVc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordController") as! ForgetPasswordController
        self.navigationController?.pushViewController(LoginVc, animated: true)
    }
    
    @IBAction func buttonLoginClick(_ sender: UIButton) {
        if let email = txtEmail.text ,let password = txtPassword.text, let employee = txtEmpno.text{
            if employee == ""{
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Enter Employee Number!")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
            }else if !email.validateEmailAddress(){
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Enter valid email address!")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
            }else if !password.validatePassword(){
                if self.isButtonEnabled {
                    //                    self.showToastAlert(message: "Enter valid password!")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
            }
        }
        
        guard let empNumber = txtEmpno.text,
              let email = txtEmail.text,
              let password = txtPassword.text else {
            // Handle missing input
            return
        }
        
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error{
                self.showToastAlert(message: "Enter correct email or password")
                print("Error :\(error.localizedDescription)")
            } else if let user = authResult?.user {
                // Login successful, check employee number in the database
                self.checkEmployeeNumberMatch(user: user, empNumber: empNumber)
            }
        }
    }
    
    @IBAction func buttonSignUpNavigation(_ sender: UIButton) {
        let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(LoginVC, animated: true)
    }
    
    //MARK: - Manage Firebase
    
    func checkEmployeeNumberMatch(user: FirebaseAuth.User, empNumber: String){
        UserDefaults.standard.set(user.displayName, forKey: "username")
        UserDefaults.standard.synchronize()
        
        // Reference to the users node in the Realtime Database
        let usersRef = Database.database().reference().child("users")
        
        // Query to check if the provided credentials exist in the database
        let query = usersRef.queryOrdered(byChild: "empNumber").queryEqual(toValue: empNumber)
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let userSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                  let user = userSnapshot.value as? [String: Any],
                  let storedEmail = user["email"] as? String
            else {
                // User not found or unable to retrieve user data
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Employee number not exists!")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
                return
            }
            
            self.txtEmpno.text = ""
            self.txtEmail.text = ""
            self.txtPassword.text = ""
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            
        }
    }
}
