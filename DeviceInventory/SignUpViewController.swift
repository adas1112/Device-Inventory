import UIKit
import FirebaseAuth
import Firebase
class SignUpViewController: UIViewController {
    
    // Firebase reference
    var databaseRef: DatabaseReference!
    var isButtonEnabled = true
    var imageURL = ""
    
    @IBOutlet weak var backTapped: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtName: UITextField!{
        didSet{
            txtName.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtName.setIcon(UIImage(imageLiteralResourceName: "name1"))
        }
    }
    
    @IBOutlet weak var txtEmail: UITextField!{
        didSet{
            txtEmail.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtEmail.setIcon(UIImage(imageLiteralResourceName: "email1"))
        }
    }
    
    @IBOutlet weak var txtEmpno: UITextField!{
        didSet{
            txtEmpno.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtEmpno.setIcon(UIImage(imageLiteralResourceName: "employee1"))
        }
    }
    
    @IBOutlet weak var txtDepartment: UITextField!{
        didSet{
            txtDepartment.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtDepartment.setIcon(UIImage(imageLiteralResourceName: "department1"))
        }
    }
    
    @IBOutlet weak var txtPassword: UITextField!{
        didSet{
            txtPassword.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtPassword.setIcon(UIImage(imageLiteralResourceName: "password1"))
        }
    }
    
    @IBOutlet weak var txtConPass: UITextField!{
        didSet{
            txtConPass.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtConPass.setIcon(UIImage(imageLiteralResourceName: "password1"))
        }
    }
    
    
    @IBOutlet weak var curveView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldBoreder()
        hideKeyboard()
        
        txtPassword.enablePasswordToggle()
        txtConPass.enablePasswordToggle()
        
        // Add observers for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        txtName.delegate = self
        txtEmail.delegate = self
        txtEmpno.delegate = self
        txtDepartment.delegate = self
        txtPassword.delegate = self
        txtConPass.delegate = self
        
        //Back Icon Navigation Using Tap Gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        backTapped.isUserInteractionEnabled = true
        backTapped.addGestureRecognizer(tapGesture)
        
        
        let cornerRadius: CGFloat = 60
        let maskPath = UIBezierPath(
            roundedRect: curveView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        curveView.layer.mask = maskLayer
        
        // Set up Firebase database reference
        databaseRef = Database.database().reference()
        
        
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
    
    
    
    @objc func imageViewTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.textFieldReturn(textField)
    }
    
    
    func textFieldBoreder(){
        txtName.layer.borderColor = UIColor.gray.cgColor
        txtName.layer.borderWidth = 1.5
        txtName.layer.cornerRadius = 25.0
        txtName.clipsToBounds = true
        
        txtEmail.layer.borderColor = UIColor.gray.cgColor
        txtEmail.layer.borderWidth = 1.5
        txtEmail.layer.cornerRadius = 25.0
        txtEmail.clipsToBounds = true
        
        txtEmpno.layer.borderColor = UIColor.gray.cgColor
        txtEmpno.layer.borderWidth = 1.5
        txtEmpno.layer.cornerRadius = 25.0
        txtEmpno.clipsToBounds = true
        
        txtDepartment.layer.borderColor = UIColor.gray.cgColor
        txtDepartment.layer.borderWidth = 1.5
        txtDepartment.layer.cornerRadius = 25.0
        txtDepartment.clipsToBounds = true
        
        txtPassword.layer.borderColor = UIColor.gray.cgColor
        txtPassword.layer.borderWidth = 1.5
        txtPassword.layer.cornerRadius = 25.0
        txtPassword.clipsToBounds = true
        
        txtConPass.layer.borderColor = UIColor.gray.cgColor
        txtConPass.layer.borderWidth = 1.5
        txtConPass.layer.cornerRadius = 25.0
        txtConPass.clipsToBounds = true
    }
    
    @IBAction func buttonSignUpClick(_ sender: UIButton) {
        
        //Validations of sign up screen
        if let firstname = txtName.text , let email = txtEmail.text ,let employee = txtEmpno.text , let department = txtDepartment.text , let password = txtPassword.text , let conPasword = txtConPass.text{
            
            if firstname == ""{
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Enter your name")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
                return
            }else if !email.validateEmailAddress(){
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Enter valid email address")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
                return
            }else if employee == ""{
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Enter Employee Number!")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
                return
                
            }else if department == ""{
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Enter department name")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
                return
                
            }else if !password.validatePassword(){
                if self.isButtonEnabled {
                    self.showToastAlert(message: "Min 4 character and 4 number")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
                return
                
            }else if password != conPasword {
                if self.isButtonEnabled {
                    self.showToastAlert(message: "password not matched!")
                    self.isButtonEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isButtonEnabled = true
                    }
                }
                return
            }
        }
        
        if let firstname = txtName.text, let email = txtEmail.text, let employee = txtEmpno.text, let department = txtDepartment.text, let password = txtPassword.text, let _ = txtConPass.text {
            
            // Check if the email already exists in Firebase
            checkEmailExistence(email: email, empNumber: employee) { [weak self] (emailExists,empNumberExists) in
                guard let self = self else { return }
                
                if emailExists {
                    // Email exists, show an email alert
                    self.alertView(title: "Alert", message: "Email already exists", alertStyle: .alert, actionTitles: ["Back to login"], actionStyles: [.default], actions: [{_ in
                        self.navigationController?.popViewController(animated: true)
                    }])
                } else if empNumberExists {
                    // Employee number exists, show an employee number alert
                    self.alertView(title: "Alert", message: "Employee Number already exists", alertStyle: .alert, actionTitles: ["Back to login"], actionStyles: [.default], actions: [{_ in
                        self.navigationController?.popViewController(animated: true)
                    }])
                }
                
                else {
                    // Email does not exist, proceed to sign up
                    self.signUpUser(name: firstname, empNumber: employee, email: email, department: department, password: password)
                }
            }
        }
    }
    
    
    // Function to check if the email already exists in Firebase
    func checkEmailExistence(email: String,empNumber: String, completion: @escaping (Bool, Bool) -> Void) {
        
        let usersRef = Database.database().reference().child("users")
        let emailQuery = usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email)
        let empNumberQuery = usersRef.queryOrdered(byChild: "empNumber").queryEqual(toValue: empNumber)
        let dispatchGroup = DispatchGroup()
        
        var emailExists = false
        var empNumberExists = false
        
        dispatchGroup.enter()
        emailQuery.observeSingleEvent(of: .value) { snapshot in
            emailExists = snapshot.exists()
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        empNumberQuery.observeSingleEvent(of: .value) { snapshot in
            empNumberExists = snapshot.exists()
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            // Pass true if either email or employee number exists
            completion(emailExists, empNumberExists)
        }
    }
    
    // Function to sign up the user after email existence check
    func signUpUser(name: String, empNumber: String, email: String, department: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Error occurred during sign-up
                print("Error creating user:", error.localizedDescription)
                self.showToastAlert(message: "Error occurred during sign-up")
            } else if let authResult = authResult {
                // User created successfully with Firebase Authentication
                let userID = authResult.user.uid // Get the UID from Firebase Authentication
                let data: [String: Any] = [
                    "name": name,
                    "empNumber": empNumber,
                    "email": email,
                    "department": department,
                    "imageURL": self.imageURL
                ]
                
                let usersRef = Database.database().reference().child("users").child(userID)
                usersRef.setValue(data) { error, ref in
                    if let error = error {
                        // Error storing user data in the Realtime Database
                        print("Error storing user data:", error.localizedDescription)
                        self.showToastAlert(message: "Error storing user data")
                    } else {
                        // User data stored successfully in the Realtime Database
                        self.alertView(title: "Successful!!", message: "User Created Successfully!", alertStyle: .alert, actionTitles: ["Login"], actionStyles: [.default], actions: [{ _ in
                            self.navigationController?.popViewController(animated: true)
                        }])
                    }
                }
            }
        }
    }
    
    @IBAction func buttonLoginNavigation(_ sender: UIButton) {
    }
}
