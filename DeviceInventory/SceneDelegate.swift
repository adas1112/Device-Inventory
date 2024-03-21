//
//  SceneDelegate.swift
//  DeviceInventory
//
//  Created by Bilal on 28/02/24.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let window = UIWindow(windowScene: windowScene)

      
//        if let loggedUsername = UserDefaults.standard.string(forKey: "username") {
//              print("User defaults username: \(loggedUsername)")
//          } else {
//              print("User defaults username not found")
//          }
//
//           // if user is logged in before
//           if let loggedUsername = UserDefaults.standard.string(forKey: "username") {
//               // instantiate the main tab bar controller and set it as root view controller
//               // using the storyboard identifier we set earlier
//
//               print("User is logged in as: \(loggedUsername)")
//
//               let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
//               window?.rootViewController = mainTabBarController
//           } else {
//               // if user isn't logged in
//               print("User is not logged in")
//
//               // instantiate the navigation controller and set it as root view controller
//               // using the storyboard identifier we set earlier
//               let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
//               window?.rootViewController = loginNavController
//           }
        Auth.auth().addStateDidChangeListener { (auth, user) in
                   if let user = user {
                       print("Firebase User is logged in as: \(user.uid)")
                    
                       let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                       window.rootViewController = mainTabBarController
                   } else {
                       print("Firebase User is not logged in")
                       
                       let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                       window.rootViewController = loginViewController
                   }
                   
                   
                   // Make the window visible
                   self.window = window
                   window.makeKeyAndVisible()
               }

    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        // change the root view controller to your specific view controller
        window.rootViewController = vc
        
        // add animation
           UIView.transition(with: window,
                             duration: 0.5,
                             options: [.transitionFlipFromLeft],
                             animations: nil,
                             completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

