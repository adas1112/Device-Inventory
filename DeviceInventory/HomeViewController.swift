//
//  HomeViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 06/03/24.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.dataSource = self
//        tableView.delegate = self
        fetchUserData()
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SignupFieldsTableViewCell
        let user = users[indexPath.row]
        
        cell.txtEmpCell.text = "Employee Number: \(user.empNumber)"
        cell.txtNameCell.text = "Name: \(user.name)"
        cell.txtEmailCell.text = "Email: \(user.email)"
        cell.txtDepartmentCell.text = "Department: \(user.department)"

        return cell
    }
    
    func fetchUserData() {
          let usersRef = Database.database().reference().child("users")

          usersRef.observeSingleEvent(of: .value) { snapshot in
              guard let userDicts = snapshot.value as? [String: [String: String]] else {
                  return
              }

              self.users = userDicts.compactMap { (key, value) in
                  guard let empNumber = value["empNumber"],
                        let email = value["email"],
                        let department = value["department"],
                        let name = value["name"] else {
                      return nil
                  }

                  return User(empNumber: empNumber, email: email, department: department, name: name)
              }

              // Reload the UITableView to reflect the updated data
//              self.tableView.reloadData()
          }
      }
    
    
}

//create model struct
struct User {
    var empNumber: String
    var email: String
    var department: String
    var name: String
}
