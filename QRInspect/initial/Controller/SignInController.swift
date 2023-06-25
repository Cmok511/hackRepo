//
//  SignInController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift

final class SignInController: UIViewController {
    
    @IBOutlet weak private var loginTF: UITextField!
    @IBOutlet weak private var passTF: UITextField!
    @IBOutlet weak private var backView: UIView!
    @IBOutlet weak private var nextButton: UIButton!
    @IBOutlet weak private var spinner: UIActivityIndicatorView!

    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureToHideKeyboard()
    }
    
    //MARK: view will apear
    override func viewWillAppear(_ animated: Bool) {
        backView.topRadius()
        nextButton.addSmallRadius()
        
        spinner.stopAnimating()
    }
    
    //MARK: send code
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
            RSignUpModel.fetchLogin(login: loginTF.text!.trimmingCharacters(in: .whitespaces), password: passTF.text!.trimmingCharacters(in: .whitespaces)) //try to login
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
