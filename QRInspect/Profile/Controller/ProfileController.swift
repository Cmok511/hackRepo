//
//  ProfileController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift

final class ProfileController: UIViewController {
    
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var position: UILabel!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var company: UILabel!
    @IBOutlet private weak var aboutAppView: UIView!
    @IBOutlet private weak var exitView: UIView!

    //MARK: LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    //MARK: view will apear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }

    //MARK: setupUI
    private func setupUI() {
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.borderWidth = 3
        avatar.setOval()
        if getProfile().avatar == nil {
            avatar.image = UIImage(named: "agronomLogo")
        } else {
            avatar.sd_setImage(with: URL(string: getProfile()?.avatar ?? ""), placeholderImage: UIImage(named: "AvatarBlack"), options: [], context: [:])
        }
        exitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitApp)))
        aboutAppView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutApp)))
        updateProfile()
    }

    //MARK: configure cell
    private func configure() {
        name.text = "\(getProfile().firstName ?? "") \(getProfile().lastName ?? "") \(getProfile().patronymic ?? "")"
        position.text = (getProfile().position?.name ?? "Агроном")
        company.text = "Château de Talu"
        
    }

    //MARK: close this controller
    @IBAction private func close(_ sender: UIButton){
        dismiss(animated: true)
    }

    //MARK: exit app
    @objc private func exitApp(_ sender: Any){
        self.exitAppClearKeychain()
    }
    
    //MARK: about app
    @objc private func aboutApp(_ sender: Any){
       performSegue(withIdentifier: "aboutApp", sender: nil)
    }

    // MARK: update profile
    private func updateProfile() {
        firstly{
            ProfileModel.fetchProfile()
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.updateProfileData(profile: data.data!)
                self?.viewWillAppear(true)
            }
        }.catch{ error in
            print(error.localizedDescription)
        }
    }
}
