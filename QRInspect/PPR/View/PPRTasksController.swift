//
//  PPRTasksController.swift
//  QRInspect
//
//

import Foundation
import UIKit
import PromiseKit
import Toast_Swift

protocol PPRTasksControllerDelegate: UIViewController {
    func reloadData()
}
//MARK: - Class
final class PPRTasksController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLable: UILabel!
    @IBOutlet private weak var endButton: UIButton!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonsContainerView: UIView!
    
    private let model = PPRModel()
    var isStarted = false
    var titleText = ""
    var fromIsActive = true
    var taskID: Int?
    private var maintenanceTasks: [MaintenanceTask] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
     var inactiveTasks: [WorkTaskReports?] = []
    
    //MARK:  LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startLogic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fromIsActive {
            fatchTasks()
        }
    }
    
    private func setupUI() {
        startButton.isHidden = isStarted
        endButton.isHidden = !isStarted
        titleLable.text = titleText
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 12, right: 0)
        endButton.addRadius()
        startButton.blueBorder()
        startButton.addRadius()
        startButton.addTarget(self, action: #selector(startPPR), for: .touchUpInside)
        endButton.addTarget(self, action: #selector(endPPR), for: .touchUpInside)
    }
    
    private func startLogic() {
        buttonsContainerView.isHidden = !fromIsActive
    }
    
    private func fatchTasks() {
        guard let taskID else { return }
        spinner.startAnimating()
        firstly {
            model.fatchMaintenanceTasks(id: taskID)
        }.done { data in
            if data.message?.lowercased() == "ok" {
                if !(data.data?.isEmpty ?? false) {
                    self.maintenanceTasks = data.data ?? []
                }
            } else {
                self.view.makeToast(data.description)
            }
            self.spinner.stopAnimating()
        }.catch { error in
            self.spinner.stopAnimating()
            print(error)
            self.view.makeToast("Что-то пошло не так")
        }
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func scanQR() {
        if isStarted {
            guard let viewController = UIStoryboard(name: "Detour", bundle: nil).instantiateViewController(withIdentifier: "QRScannerController") as? QRScannerController else {
                return
            }
            viewController.modalPresentationStyle = .overFullScreen
            viewController.isPPR = true
            viewController.delegatePPR = self
            present(viewController, animated: true)
        } else  {
            view.makeToast("Начните выполнение ППР")
        }
    }
    
    @objc private func startPPR() {
        spinner.startAnimating()
        firstly {
            model.startPPR(id: taskID ?? 0)
        }.done { [weak self ] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                startButton.isHidden = true
                endButton.isHidden = false
                isStarted = true
            } else {
                view.makeToast(data.description)
            }
            spinner.stopAnimating()
        }.catch { error in
            self.spinner.stopAnimating()
            self.view.makeToast("Что-то пошло не так")
            print(error)
        }
    }
    
    @objc private func endPPR() {
        guard let taskID else { return }
        spinner.startAnimating()
        firstly {
            model.endPPR(pprID: taskID , comment: "")
        }.done { [weak self] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                view.makeToast("Отчет успешно отправлен", duration: 0.7) { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            } else  {
                view.makeToast(data.description)
            }
            spinner.stopAnimating()
        }.catch { error in
            self.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
}
//MARK: - UITableViewDataSource

extension PPRTasksController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fromIsActive ? maintenanceTasks.count : inactiveTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPRTaskTableViewCell.reuseID, for: indexPath) as! PPRTaskTableViewCell
        if fromIsActive {
            cell.qrButton.addTarget(self, action: #selector(scanQR), for: .touchUpInside)
            cell.configure(ppr: maintenanceTasks[indexPath.row])
        } else {
            cell.configure(pprWithReports: inactiveTasks[indexPath.row])
        }
        return cell
    }
}
extension PPRTasksController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fromIsActive {
            scanQR()
        } else {
            guard let viewController = UIStoryboard(name: "Tasks", bundle: nil).instantiateViewController(withIdentifier: "OneTaskController") as? OneTaskController else {
                return
            }
            viewController.state = .fromInactitePPR
            viewController.inactivePPRReports = inactiveTasks[indexPath.item]
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
}



//MARK: - PPRTasksControllerDelegate

extension PPRTasksController : PPRTasksControllerDelegate {
    func reloadData() {
        fatchTasks()
    }
}
