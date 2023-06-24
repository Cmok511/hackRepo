//
//  QRScannerController.swift
//  QRInspect
//
//

import Foundation
import UIKit
import MercariQRScanner
import AVFoundation
import MercariQRScanner
import PromiseKit
import Toast_Swift

final class QRScannerController: UIViewController {
    
    @IBOutlet weak var qrView: UIView!
    private let model = DetourModel()
    var isPPR = false
    
    weak var delegate: DetourTasksControllerDelegate?
    weak var delegatePPR: PPRTasksControllerDelegate?
    
    //MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.reloadData()
        if isPPR {
            delegatePPR?.reloadData()
        }
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true)
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
    
    //MARK: fatchTask
    private func fatchTask(id: Int) {
        firstly {
            model.fetchTourTask(id: id)
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
            } else  { // is not ok
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
    //MARK: fatchPPRTask
    
    private func fatchPPRTask(id: Int) {
        firstly {
            model.fetchPPRTask(id: id)
        }.done { [weak self] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                if data.data?.status != 3 {
                    guard let viewController = UIStoryboard(name: "Tasks", bundle: nil).instantiateViewController(withIdentifier: "OneTaskController") as? OneTaskController else {
                        return
                    }
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.state = .isPPR
                    viewController.pprTask = data.data
                    self.present(viewController, animated: true)
                } else  {
                    view.makeToast("Данная задача уже была выполена") { _ in
                        self.dismiss(animated: true)
                    }
                }
            } else  {
                view.makeToast(data.description) { _ in
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
    
}
//MARK: - QRScannerViewDelegate

extension QRScannerController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error.localizedDescription)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        print(code)
        guard let id = Int(code) else {
            view.makeToast("Неверный qr") { _ in
                self.dismiss(animated: true)
            }
            return }
       
        isPPR ? fatchPPRTask(id: id) : fatchTask(id: id)
    }
}
