//
//  UIAlert.swift
//  BiometricWithKeychain
//
//  Created by Mike Zarazua on 7/24/19.
//  Copyright © 2019 Mike Zarazua. All rights reserved.
//

import Foundation
import UIKit

class UIAlert
{
    //MARK: - Native UIAlertController
    public static func showOkAlert(title:String?,message:String?,preferredControllerStyle:UIAlertController.Style, preferredAlertActionStyle:UIAlertAction.Style,viewController:UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredControllerStyle)
        alert.addAction(UIAlertAction(title: "Aceptar", style: preferredAlertActionStyle, handler: nil))
        
        viewController.present(alert, animated: true)
    }
    
    /**
     this function present a native alert, with a copletion in order to perform anything yoou want in function of the parameter setted
     
     - Parameter title:
     - Parameter message:
     - Parameter preferredContollerStyle:
     - Parameter preferredAlertActionStyle:
     - Parameter viewController:
     */
    
    public static func showAlertViewWithCompletion(title:String?,message:String?,preferredControllerStyle:UIAlertController.Style, preferredAlertActionStyle:UIAlertAction.Style,viewController:UIViewController,actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void)
    {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (index, (title, style)) in actions.enumerated()
        {
            let alertAction = UIAlertAction(title: title, style: style)
            { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        
        
        viewController.present(alertViewController, animated: true)
    }
    
    /**
     - Parameter viewController: The current viewcontroller where the alert will be show
     - Parameter title: The title of the alert
     - Parameter message: The message to be displayed
     - Parameter actions: The array of actions where have a string to set what the user will read and other the style of that text
     - Parameter completion: The completion after show
     */
    static func showActionsheet(viewController: UIViewController, title: String, message: String, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void)
    {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, (title, style)) in actions.enumerated()
        {
            let alertAction = UIAlertAction(title: title, style: style)
            { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        
        if let popoverController = alertViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}
