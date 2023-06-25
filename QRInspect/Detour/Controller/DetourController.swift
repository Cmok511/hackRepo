//
//  DetourController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import PromiseKit

protocol DetourControllerProtocol : AnyObject {
    func reloadData()
}

final class DetourController: UIViewController {

    @IBOutlet weak private var activeButton: UIButton!
    @IBOutlet weak private var activeBorder: UIView!
    @IBOutlet weak private var finishedButton: UIButton!
    @IBOutlet weak private var finishedBorder: UIView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var mockStackView: UIStackView!
    @IBOutlet weak private var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var mockTextLabel: UILabel!
    private let refreshControl = UIRefreshControl()
    //pagination
    private var isActive = true
    private var hasNextActivePage = false
    private var hasNextInactivePage = false
    private var activePage = 1
    private var inactivePage = 1
    
    private let model = DetourModel()
    
    private var detours: [GettingTour] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var inactiveDetours: [InactiveToursData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
//MARK:  lifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fatchActiveTours()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isActive ? fatchActiveTours() : fatchInactiveTours()
    }
    
    private func setupUI() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
        activeButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        activeBorder.isHidden = false
        finishedBorder.isHidden = true
    }
    private func fatchActiveTours() {
        spinner.startAnimating()
        self.tableView.isHidden = false
        self.mockStackView.isHidden = true
        firstly {
            model.fatchTour(page: activePage)
        }.done { data in
            if data.message?.lowercased() == "ok" {
                if self.activePage == 1 {
                    self.detours = data.data
                } else {
                    self.detours += data.data
                }
                self.mockStackView.isHidden = !data.data.isEmpty
                self.tableView.isHidden = data.data.isEmpty
                self.mockTextLabel.text = "Нет активных обходов"
            }
            self.spinner.stopAnimating()
            self.hasNextActivePage = data.meta.pagination?.hasNext ?? false
            if self.hasNextActivePage {
                self.activePage += 1
            }
        }.catch { error in
            print("error", error.localizedDescription)
            self.mockStackView.isHidden = false
            self.tableView.isHidden = true
            self.spinner.stopAnimating()
            self.view.makeToast("Что-то пошло не так", duration: 0.4)
        }
    }
    private func fatchInactiveTours() {
        spinner.startAnimating()
        self.tableView.isHidden = false
        self.mockStackView.isHidden = true
        firstly {
            model.fatchInactiveToursTour(page: inactivePage)
        }.done { data in
            if data.message?.lowercased() == "ok" {
                if self.inactivePage == 1 {
                    self.inactiveDetours = data.data ?? []
                } else {
                    self.inactiveDetours += data.data ?? []
                }
                self.mockStackView.isHidden = !(data.data?.isEmpty ?? true)
                self.tableView.isHidden = data.data?.isEmpty ?? false
                self.mockTextLabel.text = "Нет завершенных обходов"
            } else  {
                self.view.makeToast(data.description)
            }
            self.hasNextInactivePage = data.meta?.pagination?.hasNext ?? false
            if self.hasNextInactivePage {
                self.inactivePage += 1
            }
            self.spinner.stopAnimating()
        }.catch { error in
            self.spinner.stopAnimating()
            self.mockStackView.isHidden = false
            self.tableView.isHidden = true
            self.view.makeToast("Что-то пошло не так", duration: 0.4)
            print(error)
        }
    }
    @objc private func refreshData() {
        activePage = 1
        inactivePage = 1
        let refreshData: () = isActive ? fatchActiveTours() : fatchInactiveTours()
        refreshData
        spinner.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    //MARK: SHOW ACTIVE
    @IBAction func showActive(_ sender: UIButton) {
        activeButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        activeBorder.isHidden = false
        finishedBorder.isHidden = true
        fatchActiveTours()
        isActive = true
    }
    
    //MARK: SHOW FINISHED
    @IBAction func showFinished(_ sender: UIButton) {
        activeButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        activeBorder.isHidden = true
        finishedBorder.isHidden = false
        fatchInactiveTours()
        isActive = false
    }
}
//MARK:  - UITableViewDataSource

extension DetourController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isActive ? detours.count : inactiveDetours.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetourTableViewCell.reuseID, for: indexPath) as! DetourTableViewCell
        if isActive {
            cell.configure(tour: detours[indexPath.item])
        } else  {
            cell.configure(tour: inactiveDetours[indexPath.item])
        }
        return cell
    }
}
//MARK: - UITableViewDelegate

extension DetourController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = UIStoryboard(name: "Detour", bundle: nil).instantiateViewController(withIdentifier: "DetourTasksController") as? DetourTasksController else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        viewController.delegate = self
        
        if isActive {
            viewController.titleText = detours[indexPath.row].title ?? ""
            viewController.tourID = detours[indexPath.row].id
            viewController.isStarted = detours[indexPath.row].worker != nil
            viewController.fromIsActive = true
        } else {
            viewController.titleText = inactiveDetours[indexPath.row].tour?.title ?? ""
            viewController.tourID = inactiveDetours[indexPath.row].tour?.id
            viewController.isStarted = inactiveDetours[indexPath.row].tour?.worker != nil
            viewController.fromIsActive = false
            viewController.inactiveWorkTasks = inactiveDetours[indexPath.row].taskReports ?? []
        }
        present(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isActive && hasNextActivePage {
                if indexPath.row == detours.count - 2 {
                    fatchActiveTours()
            }
        }
        
        if !isActive && hasNextInactivePage {
            if indexPath.row == inactiveDetours.count - 2 {
                fatchInactiveTours()
            }
        }
    }
}
//MARK: - DetourControllerProtocol

extension DetourController: DetourControllerProtocol {
    func reloadData() {
        isActive ? fatchActiveTours() : fatchInactiveTours()
    }
    
}
