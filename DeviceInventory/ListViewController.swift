//
//  ListViewController.swift
//  DeviceInventory
//
//  Created by Bilal on 18/03/24.
//

import UIKit

class ListViewController: UIViewController {

    
    @IBOutlet weak var circularImageView: UIImageView!
    
    
    @IBOutlet weak var curveView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply rounded corners to the left and right corners
        let cornerRadius: CGFloat = 60
        let maskPath = UIBezierPath(
            roundedRect: curveView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        curveView.layer.mask = maskLayer
        
        
    }
    

  
}
