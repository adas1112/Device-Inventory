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
    
    var isButtonEnabled = true
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        txtEmpno.delegate = self
        txtEmail.delegate = self
        txtPassword.delegate = self
    }
    
    deinit {
        // Remove keyboard event observers
        NotificationCenter.default.removeObserver(self)
    }
    
    // Function to adjust content inset when keyboard is shown
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    // Function to reset content inset when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.textFieldReturn(textField)
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
    
    @IBAction func forgetPasswordClick(_ sender: UIButton) {
        let LoginVc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordController") as! ForgetPasswordController
        self.navigationController?.pushViewController(LoginVc, animated: true)
    }
    
    @IBAction func buttonLoginClick(_ sender: UIButton) {
        
        //Validations of textFields
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
                    //
                    return
                }
                
                self.txtEmpno.text = ""
                self.txtEmail.text = ""
                self.txtPassword.text = ""
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                //            self.navigationController?.pushViewController(mainTabBarController, animated: true)
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                
            }
            
            
        
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

extension UIViewController:UITextFieldDelegate{
    
    //function for hide keyboard tap on screen
    func hideKeyboard(){
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissableKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dissmissableKeyboard(){
        view.endEditing(true)
    }
    
    
    //click return button to move next field
    func textFieldReturn(_ textField:UITextField) -> Bool{
        if let nextButton = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextButton.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return false
    }
}
//

extension UITextField {
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if isSecureTextEntry {
            button.setImage(UIImage(named: "eye_invisible"), for: .normal)
        } else {
            button.setImage(UIImage(named: "eye_visible"), for: .normal)
        }
    }
    
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -35, bottom: 0, right: 0)
        button.frame = CGRect(x: self.frame.size.width - 25, y: 5, width: 25, height: 25)
        button.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @objc func togglePasswordView(_ sender: Any) {
        if isSecureTextEntry {
            showText()
        } else {
            hideText()
        }
        setPasswordToggleImage(sender as! UIButton)
    }
    
    private func showText() {
        guard let text = self.text else { return }
        let tempText = self.text
        self.isSecureTextEntry = false
        self.text = ""
        self.text = tempText
    }
    
    private func hideText() {
        guard let text = self.text else { return }
        let tempText = self.text
        self.isSecureTextEntry = true
        self.text = ""
        self.text = tempText
    }
}
