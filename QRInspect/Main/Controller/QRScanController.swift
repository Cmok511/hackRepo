//
//  QRScanController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import MercariQRScanner
import AVFoundation
import Toast_Swift
import PromiseKit

final class QRScanController: UIViewController {

    @IBOutlet weak private var qrView: UIView!
    private let detourmodel = DetourModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
    }
    

    @IBAction private func close(_ sender: UIButton){
        dismiss(animated: true)
    }
    
    private func fatchTask(id: Int) {
        firstly {
            detourmodel.fetchTourTask(id: id)
        }.done { [weak self] data in
            guard let self else { return }
            
            if data.message?.lowercased() == "ok" {
                if data.data?.status != 3 {
                    guard let viewController = UIStoryboard(name: "Tasks", bundle: nil).instantiateViewController(withIdentifier: "OneTaskController") as? OneTaskController else {
                        return
                    }
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.workTask = data.data
                    viewController.state = .isTour
                    self.present(viewController, animated: true)
                } else  {
                    view.makeToast("Данная задача уже была выполена") { _ in
                        self.dismiss(animated: true)
                    }
                }
            } else  {
                self.view.makeToast(data.description) { _ in
                    self.dismiss(animated: true)
                }
            }
        }.catch { error in
            print(error)
            self.view.makeToast("Что-то пошло не так") { _ in
                self.dismiss(animated: true)
            }
        }
    }

    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            showAlert()
        }
    }
    
    private func setupQRScannerView() {
        let qrScannerView = QRScannerView(frame: view.bounds)
        qrView.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        qrScannerView.startRunning()
    }
    
    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    
}
//MARK: -  QRScannerViewDelegate

extension QRScanController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        guard let id = Int(code) else {
            view.makeToast("Неверный qr") { _ in
                self.dismiss(animated: true)
            }
            return }
        fatchTask(id: id)
    }
}


private extension String {
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        var st = self.replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: "-", with: "+")
        let remainder = self.count % 4
        if remainder > 0 {
            st = st.padding(toLength: st.count + 4 - remainder,
                            withPad: "=",
                            startingAt: 0)
        }
        guard let d = Data(base64Encoded: st, options: .ignoreUnknownCharacters) else{
            return nil
        }
        return String(data: d, encoding: .utf8)
    }
    
}

