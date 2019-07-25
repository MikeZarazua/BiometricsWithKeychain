//
//  ViewController.swift
//  BiometricWithKeychain
//
//  Created by Mike Zarazua on 7/24/19.
//  Copyright © 2019 Mike Zarazua. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ViewController: UIViewController {

    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var uiSwitch: UISwitch!
    private var presenter: ViewPresenter = ViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        presenter.attachDelegate(viewController: self)
        presenter.attachUIControlAction(uiControl: self.uiSwitch)
        presenter.checkIfUserHasLogged()
    }
    
    @IBAction func loginButtonAction(_ sender: Any)
    {
        guard let account = textFieldUserName.text else { return }
        guard let password = textFieldPassword.text else { return }
        
        presenter.logInUser(account: account, password: password)
    }
}

//MARK: - ViewPresenterDelegate methods
extension ViewController: ViewPresenterDelegate
{
    func didSuccessLogin(userName: String, password: String)
    {
        print("Did success Login with UserName\(userName) and password \(password) ")
        let dataArray = ["userName": userName, "password": password]
        self.performSelector(onMainThread: #selector(setTextFieldData(objectData:)), with: dataArray, waitUntilDone: true)
    }
    
    @objc func setTextFieldData(objectData: [String:String])
    {
        
        self.textFieldPassword.text = objectData["password"]
        self.textFieldUserName.text = objectData["userName"]
    }
}

