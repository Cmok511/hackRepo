//
//  AboutAppController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit

final class AboutAppController: UIViewController {

    @IBOutlet private weak var logo: UIImageView!
    @IBOutlet private weak var callWIthDeveloperView: UIView!
    @IBOutlet private weak var leaveReviewView: UIView!

    //MARK: view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        logo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAvaCoreSite)))
        callWIthDeveloperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAxasTelegram)))
        leaveReviewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leaveReview)))
    }
    
    //MARK: setupUI
    private func setupUI() {
        callWIthDeveloperView.addRadius()
        leaveReviewView.addRadius()
        callWIthDeveloperView.layer.borderWidth = 1
        callWIthDeveloperView.layer.borderColor = UIColor(named: "AVABlue")?.cgColor
        leaveReviewView.layer.borderWidth = 1
        leaveReviewView.layer.borderColor = UIColor(named: "AVABlue")?.cgColor
    }
    
    //MARK: open AVAsite
    @objc private func goAvaCoreSite(_ sender: Any!){
        UIApplication.shared.open(URL(string: "https://avacore.ru")!, options: [:], completionHandler: nil)
    }

    //MARK: open AXAS tg
    @objc private func goAxasTelegram(){
        UIApplication.shared.open(URL(string: "https://t.me/iAXAS")!, options: [:], completionHandler: nil)
    }

    //MARK: leave review bout app
    @objc private func leaveReview(){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }

    //MARK: private policy
    @IBAction private func privatePolicy(_ sender: UIButton!){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }

    //MARK: terms of condition
    @IBAction private func termsOfConditions(_ sender: UIButton!){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }

    //MARK: close this controller
    @IBAction private func close(_ sender: UIButton!){
        dismiss(animated: true)
    }
}
