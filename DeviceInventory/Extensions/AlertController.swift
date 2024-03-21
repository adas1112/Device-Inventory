//
//  AlertController.swift
//  DeviceInventory
//
//  Created by Bilal on 01/03/24.
//

import Foundation
import UIKit



extension UIViewController{
    
    public func alertView(title: String,
                          message: String,
                          alertStyle:UIAlertController.Style,
                          actionTitles:[String],
                          actionStyles:[UIAlertAction.Style],
                          actions: [((UIAlertAction) -> Void)]){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated(){
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
        
    }
    

    
    func showToastAlert(message: String, duration: TimeInterval = 3.0) {
        let toastLabel = UILabel()
               toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
               toastLabel.textColor = UIColor.white
               toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
               toastLabel.text = message
               toastLabel.alpha = 1.0
               toastLabel.layer.cornerRadius = 10
               toastLabel.clipsToBounds = true

        let toastWidth = min(view.frame.width - 40, 300) // Limit toast width for better readability
               let toastHeight = toastLabel.intrinsicContentSize.height + 20
               toastLabel.frame = CGRect(x: (view.frame.width - toastWidth) / 2, y: (view.frame.height - toastHeight) / 2, width: toastWidth, height: toastHeight)

               view.addSubview(toastLabel)

               DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                   toastLabel.removeFromSuperview()
               }
           }
}

extension UIView {
    func roundCornersAndCoverFullWidth(corners: UIRectCorner, radius: CGFloat) {
        // Set the frame to cover the entire screen
        frame = UIScreen.main.bounds
        
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
