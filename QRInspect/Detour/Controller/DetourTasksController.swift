//
//  DetourTasksController.swift
//  QRInspect
//
//

import Foundation
import UIKit
import PromiseKit
import Toast_Swift

protocol DetourTasksControllerDelegate: AnyObject {
    func reloadData()
}

final class DetourTasksController : UIViewController {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var startTaskButton: UIButton!
    @IBOutlet weak private var doneButton: UIButton!
    @IBOutlet weak private var buttonsStack: UIStackView!
    @IBOutlet weak private var spinner: UIActivityIndicatorView!
    @IBOutlet weak private var bottomButtonsContainer: UIView!
    
    private let model = DetourModel()
    weak var delegate: DetourControllerProtocol?
    
    var workTasks: [WorkTask] = []
    var inactiveWorkTasks: [TourTaskReports] = []
    var titleText = ""
    var tourID: Int?
    var isStarted = false
    var fromIsActive = false
    
    // textView for allert
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    //MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        startLogic()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fromIsActive {
            fetchTourTasks()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.reloadData()
    }
    
    //isActive
    private func fetchTourTasks() {
        guard let tourID else { return }
        spinner.startAnimating()
        firstly {
            model.fatchTourTasks(id: tourID)
        }.done { [weak self] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                workTasks = data.data ?? []
                tableView.reloadData()
            } else {
                view.makeToast(data.description)
            }
            spinner.stopAnimating()
        }.catch { error in
            print(error)
            self.spinner.stopAnimating()
            self.view.makeToast("Что-то пошло не так")
        }
    }
        
    private func startLogic() {
        startTaskButton.isHidden = isStarted
        buttonsStack.isHidden = !isStarted
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 12, right: 0)
        titleLabel.text = titleText
        startTaskButton.addRadius()
        startTaskButton.blueBorder()
        doneButton.addRadius()
        bottomButtonsContainer.isHidden = !fromIsActive
        startTaskButton.addTarget(self, action: #selector(startTour), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(endTour), for: .touchUpInside)
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    //MARK:  StartTour
    
    @objc private func startTour() {
        guard let tourID else {return}
        firstly {
            model.startTour(tourID: tourID)
        }.done { [weak self] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                view.makeToast("Обход начат", duration: 0.5)
                isStarted = data.data?.worker != nil
                startLogic()
                isStarted = true
                startTaskButton.isHidden = true
                buttonsStack.isHidden = false
            } else  {
                view.makeToast(data.description)
            }
        }.catch { error in
            print(error.localizedDescription)
            self.view.makeToast("Что-то пошло не так")
        }
    }
    
    //MARK:  EndTour
    @objc private func endTour() {
        var isComplited = false
        workTasks.forEach {
            if $0.status == 1 || $0.status == 3 {
                isComplited = true
            }
        }
        isComplited ? sendReport(comment: nil) : showAllert()
    }
    
    private func showAllert() {
        let alertController = UIAlertController(title: "Добавьте отчет \n\n\n\n\n", message: nil, preferredStyle: .alert)

           let cancelAction = UIAlertAction.init(title: "Отмена", style: .default) { (action) in
               alertController.view.removeObserver(self, forKeyPath: "bounds")
           }
           alertController.addAction(cancelAction)

           let saveAction = UIAlertAction(title: "Отправить", style: .default) { (action) in
               let enteredText = self.textView.text
               alertController.view.removeObserver(self, forKeyPath: "bounds")
               self.sendReport(comment: enteredText ?? "")
           }
           alertController.addAction(saveAction)

           alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
           textView.backgroundColor = UIColor.white
           textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
           alertController.view.addSubview(self.textView)

           self.present(alertController, animated: true, completion: nil)
    }
    
    private func sendReport(comment: String?) {
        guard let id = self.tourID else { return }
        firstly {
            self.model.endTour(tourID: id, comment: comment)
        }.done { [weak self] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                doneButton.isEnabled = false
                view.makeToast("Обход завершен") { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            } else  {
                view.makeToast(data.description)
            }
        }.catch { error in
            self.view.makeToast("Что-то пошло не так")
            print(error)
        }
    }
    
    @objc private func gotoScanQR() {
        if isStarted {
            guard let viewController = UIStoryboard(name: "Detour", bundle: nil).instantiateViewController(withIdentifier: "QRScannerController") as? QRScannerController else {
                return
            }
            viewController.delegate = self
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: true)
        } else  {
            view.makeToast("Начните обход")
        }
    }
    
    //for allert
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 8
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = 90

                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
    }
}
//MARK: - UITableViewDataSource

extension DetourTasksController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fromIsActive ? workTasks.count : inactiveWorkTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetourTaskTableViewCell.reuseID, for: indexPath) as! DetourTaskTableViewCell
        if fromIsActive {
            cell.configure(task: workTasks[indexPath.row])
            cell.qrButton.tag = indexPath.row
            cell.qrButton.addTarget(self, action: #selector(gotoScanQR), for: .touchUpInside)
        } else  {
            cell.configureReport(task: inactiveWorkTasks[indexPath.row])
        }
        return cell
    }
}
//MARK: - UITableViewDelegate

extension DetourTasksController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fromIsActive {
            gotoScanQR()
        } else {
            guard let viewController = UIStoryboard(name: "Tasks", bundle: nil).instantiateViewController(withIdentifier: "OneTaskController") as? OneTaskController else {
                return
            }
            viewController.inactiveToursReports = inactiveWorkTasks[indexPath.row]
            viewController.state = .fromInactiteTour
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
            
        }
    }
}

// MARK: - DetourTasksControllerDelegate
extension DetourTasksController: DetourTasksControllerDelegate {
    func reloadData() {
        fetchTourTasks()
    }
}
