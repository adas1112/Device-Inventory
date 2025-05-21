//
//  UITextFieldExtension.swift
//  DeviceInventory
//
//  Created by Bilal on 20/05/25.
//

import Foundation
import UIKit

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
