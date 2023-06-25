//
//  SignInController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift

class SignInController: UIViewController {
    
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureToHideKeyboard()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        backView.topRadius()
        nextButton.addSmallRadius()
        
        spinner.stopAnimating()
    }
    
    // MARK: SEND CODE
    @IBAction func signIn(_ sender: UIButton) {
        if loginTF.text?.trimmingCharacters(in: .whitespaces) == "" {
            view.makeToast("Укажите логин")
            return
        }
        
        if passTF.text?.trimmingCharacters(in: .whitespaces) == "" {
            view.makeToast("Укажите пароль")
            return
        }
        
        spinner.startAnimating()
        firstly{
            RSignUpModel.fetchLogin(login: loginTF.text!.trimmingCharacters(in: .whitespaces), password: passTF.text!.trimmingCharacters(in: .whitespaces))
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                
                do {
                    try Constants.keychain.set(data.data?.token ?? "", key: "accessToken")
                }
                UserDefaults.standard.set(true, forKey: "isRegistered")
                let sBoard = UIStoryboard(name: "TabBar", bundle: .main)
                let vc = sBoard.instantiateInitialViewController()
                vc?.modalPresentationStyle = .fullScreen
                self?.present(vc!, animated: true)
                self?.spinner.stopAnimating()
               
                
            } else {
                self?.spinner.stopAnimating()
                self?.view.makeToast(data.errorDescription)
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            self?.view.makeToast(error.localizedDescription)
        }
    }
}
