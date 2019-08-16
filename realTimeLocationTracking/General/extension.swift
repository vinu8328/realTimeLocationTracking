//
//  utiles.swift
//  realTimeLocationTracking
//
//  Created by Vinayak Tudayekar on 15/08/19.
//  Copyright © 2019 Vinayak Tudayekar. All rights reserved.
//
import Foundation
import UIKit
extension UIViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showAlert(_ messageString:String)
    {
    let alertController = UIAlertController(title: "realTimeLocationTracking", message: messageString, preferredStyle: .alert)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
        
        if #available(iOS 10.0, *)
        {
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsUrl)
        }
        else
        {
            // UIApplication.shared.openURL(URL(string: "prefs:root=LOCATION_SERVICES")!)
            UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
            
        }
        
    }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
        UIAlertAction in
        NSLog("Cancel Pressed")
        
        alertController.dismiss(animated: true, completion: nil)
    }
    
    
    // Add the actions
    alertController.addAction(settingsAction)
    alertController.addAction(cancelAction)
    
    // Present the controller
    self.present(alertController, animated: true, completion: nil)
    }
}

