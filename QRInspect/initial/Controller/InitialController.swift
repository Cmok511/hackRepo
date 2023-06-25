//
//  IntitialController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift

class InitialController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Constants.keychain["accessToken"] != nil && UserDefaults.standard.bool(forKey: "isRegistered") == true {
            updateProfile()
        } else {
            startApp()
        }
    
    }
    
    func startApp() {
        //        logo.alpha = 0
        DispatchQueue.main.async {
            sleep(2)
            
            
            if UserDefaults.standard.bool(forKey: "isRegistered"){
                let sBoard = UIStoryboard(name: "TabBar", bundle: .main)
                let vc = sBoard.instantiateInitialViewController()
                vc?.modalPresentationStyle = .fullScreen
                vc?.modalTransitionStyle = .crossDissolve
                self.present(vc!, animated: false, completion: nil)
            } else {
                self.performSegue(withIdentifier: "signUp", sender: nil)
            }
            
            
        }
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseIn, animations: {
            self.logo.alpha = 1
        })
    }
    
    
    // MARK: UPDATE PROFILE
    func updateProfile(){
        spinner.startAnimating()
        firstly{
            ProfileModel.fetchProfile()
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                self?.updateProfileData(profile: data.data!)
                self?.startApp()
            } else {
                self?.spinner.stopAnimating()
                self?.startApp()
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
            self?.startApp()
        }
    }
}
