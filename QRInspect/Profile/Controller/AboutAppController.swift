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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        logo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAvaCoreSite)))
        callWIthDeveloperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAxasTelegram)))
        leaveReviewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leaveReview)))
    }
    
    
    private func setupUI() {
        callWIthDeveloperView.addRadius()
        leaveReviewView.addRadius()
        callWIthDeveloperView.layer.borderWidth = 1
        callWIthDeveloperView.layer.borderColor = UIColor(named: "AVABlue")?.cgColor
        leaveReviewView.layer.borderWidth = 1
        leaveReviewView.layer.borderColor = UIColor(named: "AVABlue")?.cgColor
    }
    
    
    @objc private func goAvaCoreSite(_ sender: Any!){
        UIApplication.shared.open(URL(string: "https://avacore.ru")!, options: [:], completionHandler: nil)
    }
    
    @objc private func goAxasTelegram(){
        UIApplication.shared.open(URL(string: "https://t.me/iAXAS")!, options: [:], completionHandler: nil)
    }
    
    @objc private func leaveReview(){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }
    
    @IBAction private func privatePolicy(_ sender: UIButton!){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }
    @IBAction private func termsOfConditions(_ sender: UIButton!){
        UIApplication.shared.open(URL(string: "https://apple.com")!, options: [:], completionHandler: nil)
    }
    
    @IBAction private func close(_ sender: UIButton!){
        dismiss(animated: true)
    }
}
