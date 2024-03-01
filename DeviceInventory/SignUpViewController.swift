

import UIKit
import FirebaseAuth
import Firebase
class SignUpViewController: UIViewController {
    
    // Firebase reference
    var databaseRef: DatabaseReference!
    
    
    @IBOutlet weak var backTapped: UIImageView!
    
    
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
    
    
    @objc func imageViewTapped() {
        navigationController?.popViewController(animated: true)
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
                alertView(title: "Alert", message: "Enter your name", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                return
            }else if !email.validateEmailAddress(){
                alertView(title: "Alert", message: "Enter valid email address", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in}])
                return
            }else if employee == ""{
                alertView(title: "Alert", message: "Enter employee no", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in}])
                return
                
            }else if department == ""{
                alertView(title: "Alert", message: "Enter Department name", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in}])
                return
                
            }else if !password.validatePassword(){
                alertView(title: "Alert", message: "Enter valid password", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in }])
                return
                
            }else if password != conPasword {
                alertView(title: "Alert", message: "Password not matched!", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in}])
                return
            }
            
            
        }
        
        if let firstname = txtName.text, let email = txtEmail.text, let employee = txtEmpno.text, let department = txtDepartment.text, let password = txtPassword.text, let conPasword = txtConPass.text {
            
            
            
            // Check if the email already exists in Firebase
            checkEmailExistence(email: email) { [weak self] (emailExists) in
                guard let self = self else { return }
                
                if emailExists {
                    // Email already exists, show an alert
                    self.alertView(title: "Alert", message: "Email already exists", alertStyle: .alert, actionTitles: ["Back to login"], actionStyles: [.default], actions: [{_ in
                        self.navigationController?.popViewController(animated: true)
                    }])
                } else {
                    // Email does not exist, proceed to sign up
                    self.signUpUser(name: firstname, empNumber: employee, email: email, department: department, password: password)
                }
            }
        }
    }
    
    
    // Function to check if the email already exists in Firebase
    func checkEmailExistence(email: String, completion: @escaping (Bool) -> Void) {
        let usersRef = Database.database().reference().child("users")
        
        usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    // Function to sign up the user after email existence check
    func signUpUser(name: String, empNumber: String, email: String, department: String, password: String) {
        let usersRef = Database.database().reference().child("users")
        
        
        
        
        // Obtain values from text fields
        guard let name = txtName.text,
              let empNumber = txtEmpno.text,
              let email = txtEmail.text,
              let department = txtDepartment.text,
              let password = txtPassword.text else {
            return
        }
        
        
        // Create a data dictionary
        let data: [String: Any] = [
            "name": name,
            "empNumber": empNumber,
            "email": email,
            "department": department,
            "password": password
        ]
        
        
        
        let userReference = databaseRef.child("users").childByAutoId()
        userReference.setValue(data){
            (error, ref) in
            if let err = error {
                self.alertView(title: "Alert", message: "Data Not Stored", alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default], actions: [{_ in}])
            }else{
                self.alertView(title: "Successful!!", message: "User Created Successfully!", alertStyle: .alert, actionTitles: ["Login"], actionStyles: [.default], actions: [{_ in
                    
                    self.navigationController?.popViewController(animated: true)
                }])
            }
        }
    }
    
    
    @IBAction func buttonLoginNavigation(_ sender: UIButton) {
        
        
    }
    
    
    
}
