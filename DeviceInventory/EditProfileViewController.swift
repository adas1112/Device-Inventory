import UIKit
import Firebase
import FirebaseDatabase

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var curveView: UIView!
    @IBOutlet weak var backTap: UIImageView!

    let ref = Database.database().reference()
    
    @IBOutlet weak var txtName: UITextField!{
        didSet{
            txtName.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtName.setIcon(UIImage(imageLiteralResourceName: "name1"))
        }
    }
 
    @IBOutlet weak var txtEmpNo: UITextField!{
        didSet{
            txtEmpNo.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtEmpNo.setIcon(UIImage(imageLiteralResourceName: "employee1"))
        }
    }
    @IBOutlet weak var txtDepartment: UITextField!{
        didSet{
            txtDepartment.tintColor = UIColor(red: 40/255.0, green: 67/255.0, blue: 135/255.0, alpha: 1.0)
            txtDepartment.setIcon(UIImage(imageLiteralResourceName: "department1"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = saveButton.bounds // Set the frame to match the button's bounds
        
        let startColor = UIColor(red: 95.0 / 255.0, green: 106.0 / 255.0, blue: 111.0 / 255.0, alpha: 1.0).cgColor
        let endColor = UIColor(red: 147.0/255.0, green: 153.0/255.0, blue: 155.0/255.0, alpha: 1.0).cgColor
        
        // Set gradient colors
        gradientLayer.colors = [startColor, endColor]
        
        // Set gradient direction (optional)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // Horizontal gradient start point
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5) // Horizontal gradient end point
        
        // Add the gradient layer to your view
        saveButton.layer.addSublayer(gradientLayer)
        saveButton.layer.cornerRadius = 20 // Adjust the corner radius as needed
        saveButton.clipsToBounds = true
        
        let cornerRadius: CGFloat = 40
        let maskPath = UIBezierPath(
            roundedRect: curveView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        curveView.layer.mask = maskLayer
        
        fetchUserData()
        
        //Back Icon Navigation Using Tap Gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        backTap.isUserInteractionEnabled = true
        backTap.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageViewTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveDetailsClick(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }
        
        let userID = currentUser.uid  // Get the current user's ID
        
        let userData: [String: Any] = [
            "name": txtName.text ?? "",
            "empNumber": txtEmpNo.text ?? "",
            "department": txtDepartment.text ?? ""
        ]
        
        ref.child("users").child(userID).updateChildValues(userData) { error, _ in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                
                self.showToastAlert(message: "Data updated successfully")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                       // Navigate back (pop screen)
                       self.navigationController?.popViewController(animated: true)
                   }
               
            }
        }
    }
    
    func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }
        
        let userID = currentUser.uid // Get the current user's ID
        let usersRef = Database.database().reference().child("users").child(userID)
        
        usersRef.observeSingleEvent(of: .value) { snapshot,error  in
            guard let userData = snapshot.value as? [String: String] else {
                return
            }
            
            if let empNumber = userData["empNumber"],
//               let email = userData["email"],
               let department = userData["department"],
               let name = userData["name"] {
                DispatchQueue.main.async { [weak self] in
                    // Update UI with user details
                    self?.txtEmpNo.text = empNumber
//                    self?.txtEmail.text = email
                    self?.txtDepartment.text = department
                    self?.txtName.text = name
                }
            }
        }
    }
}
