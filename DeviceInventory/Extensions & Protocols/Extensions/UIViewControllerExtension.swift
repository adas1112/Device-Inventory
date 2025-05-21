//
//  UIViewControllerExtension.swift
//  DeviceInventory
//
//  Created by Bilal on 20/05/25.
//

import Foundation
import UIKit

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
