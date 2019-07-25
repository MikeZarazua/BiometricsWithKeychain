//
//  ViewPresenter.swift
//  BiometricWithKeychain
//
//  Created by Mike Zarazua on 7/24/19.
//  Copyright © 2019 Mike Zarazua. All rights reserved.
//

import Foundation
import UIKit

protocol ViewPresenterDelegate:NSObjectProtocol
{
    func didSuccessLogin(userName:String,password:String)
    
}

class ViewPresenter
{
    private let keyForPassword = "wantToSave"
    weak var delegate: ViewPresenterDelegate?
    private var viewController: UIViewController?
    private var passwordHandler: ManageAccountModel = ManageAccountKeychain()
    private var biometricHandler: BiometricLocalAuthentication = BiometricLocalAuthentication()
    
    func attachDelegate(viewController:ViewPresenterDelegate)
    {
        self.viewController = viewController as? UIViewController
        delegate = viewController
    }
    
    func attachUIControlAction(uiControl:UIControl)
    {
        uiControl.addTarget(self, action: #selector(actionUIContolState(myUIControl:)), for: .valueChanged)
        if getWantToSave()
        {
            self.setOnUIControl(myUIControl: uiControl)
        }
    }
    
    func logInUser(account:String,password:String)
    {
        guard let passwordHandler = self.passwordHandler as? ManageAccountKeychain else {return}
        passwordHandler.delegate = self
        if getWantToSave()
        {
            saveAccount(account: account)
            passwordHandler.savePassword(account: account, password: password)
        }
    }
    
    func checkIfUserHasLogged()
    {
        guard let passwordHandler = self.passwordHandler as? ManageAccountKeychain else {return}

        biometricHandler.delegate = self
        passwordHandler.delegate  = self
        if getWantToSave()
        {
            biometricHandler.authenticateUserUsingId()
        }
    }
}


extension ViewPresenter
{
    @objc private func actionUIContolState(myUIControl: UIControl)
    {
        guard let myVC = self.viewController else {return}
        guard let mySwitch = myUIControl as? UISwitch else {return}
        let state = mySwitch.isOn
        self.savePassword(wantToSave: state)
        if !state
        {
            var actions: [(String, UIAlertAction.Style)] = []
            actions.append(("Aceptar", UIAlertAction.Style.destructive))
            actions.append(("Cancelar", UIAlertAction.Style.default))
           
                UIAlert.showAlertViewWithCompletion(title: "Aviso", message: "Al deshabilitar esta opción se olvidará tu contraseña, ¿Deseas realizar esta acción?", preferredControllerStyle: .alert, preferredAlertActionStyle: .destructive, viewController: myVC, actions: actions) { (index) in
                    
                    switch index
                    {
                        case 0:
                            self.setOffUIControl(myUIControl: myUIControl)
                            self.savePassword(wantToSave: false)
                            //Remove from keychain or database the password
                            guard let account = self.getAccount() else {return}
                            self.passwordHandler.removePassword(account: account)
                        case 1:
                            self.setOnUIControl(myUIControl: myUIControl)
                            self.savePassword(wantToSave: true)
                            //Authenticate user biometric
                            self.biometricHandler.authenticateUserUsingId()
                        default:
                            break
                    }
                }
            
        }
    }
    
    private func savePassword(wantToSave:Bool)
    {
        UserDefaults.standard.set(wantToSave, forKey: keyForPassword)
    }
    
    private func removePassword()
    {
        UserDefaults.standard.removeObject(forKey: keyForPassword)
    }
    
    private func getWantToSave() -> Bool
    {
        return UserDefaults.standard.bool(forKey: keyForPassword)
    }
    
    private func setOffUIControl(myUIControl: UIControl)
    {
        guard let mySwitch = myUIControl as? UISwitch else {return}
        mySwitch.isOn = false
    }
    
    private func setOnUIControl(myUIControl: UIControl)
    {
        guard let mySwitch = myUIControl as? UISwitch else {return}
        mySwitch.isOn = true
    }
    
    private func saveAccount(account:String)
    {
        UserDefaults.standard.set(account, forKey: "account")
    }
    
    private func getAccount() -> String?
    {
        return UserDefaults.standard.string(forKey: "account")
    }
}

//Mark: ManageAccountSaveProtocol methods
extension ViewPresenter:ManageAccountSaveProtocol
{
    
    /**
     this methods handle the keychain
     **/
    func didSavePassword() {
        print("Didsaved password")
        guard let vc = viewController else {return}
        UIAlert.showOkAlert(title: "Contraseña guardada", message: "Su contraseña se guardo satisfactoriamente", preferredControllerStyle: .alert, preferredAlertActionStyle: .default, viewController: vc)
    }
    
    func didSaveUserName() {
        print("didSave userName")
    }
    
    func didGetPassword(password: String?, account: String?) {
        print("The password that we got is \(password) with account \(account)")
        guard let userName = account else {return}
        guard let password = password else {return}
        
        self.delegate?.didSuccessLogin(userName: userName, password: password)
    }
    
    func didFailedSavingPassword(error: String) {
        print("didFailedSavingPassword with error \(error)")
    }
    
    func didFailedGetPassword(error: String) {
        print("didFailedGetPassword with error \(error)")
    }
    
    func didFailedRemovingPassword(error: String) {
        print("didFailedRemovingPassword with error \(error)")
    }
}

//MARK: - BiometricLocalAuthenticationDelegate methods
extension ViewPresenter: BiometricLocalAuthenticationDelegate
{
    func userAuthenticationSuccess() {
        print("The user is logged succesfully")
        if let account = getAccount()
        {
            passwordHandler.getPassword(account: account)
        }
    }
    
    func userAuthenticationFailed(witMessage: String) {
        print("The user doesn not match")
    }
    
    
}
