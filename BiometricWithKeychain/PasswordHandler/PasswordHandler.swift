//
//  PasswordHandler.swift
//  BiometricWithKeychain
//
//  Created by Mike Zarazua on 7/24/19.
//  Copyright © 2019 Mike Zarazua. All rights reserved.
//

import Foundation

protocol ManageAccountSaveProtocol:class
{
    func didSavePassword()
    func didSaveUserName()
    func didGetPassword(password:String?, account: String?)

    func didFailedSavingPassword(error:String)
    func didFailedGetPassword(error:String)
    func didFailedRemovingPassword(error:String)
}

protocol ManageAccountModel:class
{
    func savePassword(account:String, password: String)
    func removePassword(account:String)
    func getPassword(account: String)
}

class ManageAccountKeychain: ManageAccountModel
{

    weak var delegate: ManageAccountSaveProtocol?
    
    func savePassword(account:String,password: String) {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do
        {
            try passwordItem.savePassword(password)
            self.delegate?.didSavePassword()
        }
        catch
        {
            self.delegate?.didFailedSavingPassword(error: error.localizedDescription)
        }
    }
    
    func removePassword(account:String)
    {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do
        {
            try passwordItem.deleteItem()
        }
        catch
        {
            self.delegate?.didFailedRemovingPassword(error: error.localizedDescription)
        }
    }
    
    
    /**
     This function return the password to detemrinate account
     */
    func getPassword(account: String)
    {
        guard !account.isEmpty else
        {
            //self.delegate?.didGetPassword(password: nil, account: nil)
            self.delegate?.didFailedGetPassword(error: "accopunt is empty")

            return
        }
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do
        {
            let storedPassword = try passwordItem.readPassword()
            self.delegate?.didGetPassword(password: storedPassword, account: account)
            //authenticateUser(storedPassword)
        } catch KeychainPasswordItem.KeychainError.noPassword
        {
            self.delegate?.didFailedGetPassword(error: KeychainPasswordItem.KeychainError.noPassword.localizedDescription)
            print("No saved password")
        } catch {
            self.delegate?.didFailedGetPassword(error: error.localizedDescription)
            print("Unhandled error")
        }
    }
}
