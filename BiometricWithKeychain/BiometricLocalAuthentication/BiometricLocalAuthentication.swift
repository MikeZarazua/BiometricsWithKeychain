//
//  BiometricLocalAuthentication.swift
//  BiometricWithKeychain
//
//  Created by Mike Zarazua on 7/24/19.
//  Copyright © 2019 Mike Zarazua. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

protocol BiometricLocalAuthenticationDelegate:class
{
    func userAuthenticationSuccess()
    func userAuthenticationFailed(witMessage: String)
}

class BiometricLocalAuthentication
{
    
    weak var delegate: BiometricLocalAuthenticationDelegate?
    
    /**
     1.-First call this method in the viewDidAppear in order to evaluate with the LAContext()
     the divace with the .deviceOwnerAuthentication in this way, if the user does not have registered the touchid or faceid the user can set the passcode
     if the context can evaluate the policy then we call the "evlauateIdAuthenticity(context: Context) wich determinates wich biometrci can evaluate"
     */
    func authenticateUserUsingId()
    {
        let context = LAContext()
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil)
        {
            if #available(iOS 11.0, *)
            {
                self.evaluateTocuhIdAuthenticity(context: context)
            }
        }
    }
    
    /**
     This function check if the BiometricSuported(touchId or faceId) is correct, if it is then we load the pasword form keychain and handleLogin
     
     - Parameter context: LAContext
     */
    private func evaluateTocuhIdAuthenticity(context: LAContext)
    {
        // set localiazedReason
        if #available(iOS 11.0, *) {
            let localizedReason = getLocalizedReason(biometricType: context.biometryType)
       
        
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: localizedReason)
        {
            (authSuccessful, authError) in
            if authSuccessful
            {
                    //Handle here the success authentication
                self.delegate?.userAuthenticationSuccess()
            } else
            {
                if let error = authError as? LAError
                {
                    self.delegate?.userAuthenticationFailed(witMessage: self.showError(error: error))
                }
            }
        }
        } else {
            // Fallback on earlier versions
        }
    }
    
    /**
     This function returns an string in fucntion of the localized description
     recevies:
     - Parameter biometricType: an LABiometricType that detemrinates the type of biometric supported by the device
     */
    @available(iOS 11.0, *)
    func getLocalizedReason(biometricType:LABiometryType) -> String
    {
        switch biometricType {
        case .faceID:
            return "Message for faceId"
        case .touchID:
            return "Message for touchId"
        case .none:
            return "Message for no Id Supported"
        default:
            return "no option vaiable"
        }
    }
    
    func showError(error: LAError) -> String
    {
        var message: String = ""
        switch error.code {
        case LAError.authenticationFailed:
            message = "La autenticación fallo"//"Authentication was not successful because the user failed to provide valid credentials. Please enter password to login."
            //self.performSelector(onMainThread: #selector(setOffSwitch), with: nil, waitUntilDone: true)
            break
        case LAError.userCancel:
            message = "Autenticaición cancelada"//"Authentication was canceled by the user"
            //self.performSelector(onMainThread: #selector(setOffSwitch), with: nil, waitUntilDone: true)
            
            break
        case LAError.userFallback:
            message = "Autenticación cancelada"//"Authentication was canceled because the user tapped the fallback button"
            //self.performSelector(onMainThread: #selector(setOffSwitch), with: nil, waitUntilDone: true)
            
            break
            //        case LAError.biometryNotEnrolled:
            //            message = "Authentication could not start because Touch ID has no enrolled fingers."
        //            break
        case LAError.passcodeNotSet:
            message = "No tiene un passcode agregado a este dispositivo"//"Passcode is not set on the device."
            //self.performSelector(onMainThread: #selector(setOffSwitch), with: nil, waitUntilDone: true)
            
            break
        case LAError.systemCancel:
            message = "Autenticación cancelada por el sistema"//"Authentication was canceled by system"
            //self.performSelector(onMainThread: #selector(setOffSwitch), with: nil, waitUntilDone: true)
            
            break
        default:
            message = error.localizedDescription
            break
        }
        //self.showPopupWithMessage(message)
        print(message)
        return message
    }
}



