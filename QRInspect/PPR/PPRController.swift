//
//  PPRController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift


final class PPRController: UIViewController {

    @IBOutlet private weak var activeButton: UIButton!
    @IBOutlet private weak var activeBorder: UIView!
    @IBOutlet private weak var finishedButton: UIButton!
    @IBOutlet private weak var finishedBorder: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var mockImageStack: UIStackView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var mockTextLabel: UILabel!
    private let refreshControll = UIRefreshControl()
    
    private var isActive: Bool = true
    private let model = PPRModel()
    private var activePPR: [Maintenance] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var inactivePPR: [InactivePPR] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    //pagination
    private var activePage = 1
    private var inactivePage = 1
    private var hesNextActivePage = true
    private var hesNextInactivePage = true
   
    //MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadActivePPR()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isActive ? (activePage = 1) : (inactivePage = 1)
        isActive ? loadActivePPR() : loadInactivePPR()
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControll
        refreshControll.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 12, right: 0)
        activeButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        activeBorder.isHidden = false
        finishedBorder.isHidden = true
    }
    
    @objc private func refreshData() {
        isActive ? loadActivePPR() : loadInactivePPR()
        spinner.stopAnimating()
        refreshControll.endRefreshing()
    }
    
    private func loadActivePPR() {
        spinner.startAnimating()
        firstly {
            model.fetchMaintenance(page: activePage)
        }.done { [weak self] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                if activePage == 1 {
                    activePPR = data.data ?? []
                } else {
                    activePPR += data.data ?? []
                }
                tableView.isHidden = data.data?.isEmpty ?? true
                mockImageStack.isHidden = !(data.data?.isEmpty ?? false)
                mockTextLabel.text = "Нет активных \n плановых ремонтов"
            } else {
                view.makeToast(data.description)
            }
            hesNextActivePage = data.meta?.pagination?.hasNext ?? false
            activePage = hesNextActivePage ? activePage + 1 : activePage
            self.spinner.stopAnimating()
        }.catch { error in
            self.spinner.stopAnimating()
            self.view.makeToast("Что-то пошло не так")
            print(error.localizedDescription)
        }
    }
    
    private func loadInactivePPR() {
        spinner.startAnimating()
        firstly {
            model.fetchInactiveMaintenance(page: inactivePage)
        }.done { data in
            if data.message?.lowercased() == "ok" {
                if self.inactivePage == 1 {
                    self.inactivePPR = data.data
                } else  {
                    self.inactivePPR += data.data
                }
                self.tableView.isHidden = data.data.isEmpty
                self.mockImageStack.isHidden = !data.data.isEmpty
                self.mockTextLabel.text = "Нет завершённых \n плановых ремонтов"
            }
            self.hesNextInactivePage = data.meta?.pagination?.hasNext ?? false
            if self.hesNextInactivePage {
                self.inactivePage += 1
            }
            self.spinner.stopAnimating()
        }.catch { error in
            self.spinner.stopAnimating()
            print(error)
        }
        
        
    }
    
    
    //MARK: SHOW ACTIVE
    @IBAction private func showActive(_ sender: UIButton) {
        activeButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        activeBorder.isHidden = false
        finishedBorder.isHidden = true
        isActive = true
        activePage = 1
        loadActivePPR() 
    }
    
    //MARK: SHOW FINISHED
    @IBAction private func showFinished(_ sender: UIButton) {
        activeButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        activeBorder.isHidden = true
        finishedBorder.isHidden = false
        isActive = false
        inactivePage = 1
        loadInactivePPR()
    }
}
//MARK: - UITableViewDataSource

extension PPRController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isActive ? activePPR.count : inactivePPR.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPRTableViewCell.reuseID, for: indexPath) as! PPRTableViewCell
        if isActive {
            cell.configure(maintenance: activePPR[indexPath.item])
        } else {
            cell.configure(inactivePPR: inactivePPR[indexPath.row])
        }
        return cell
    }
}
//MARK: - UITableViewDelegate

extension PPRController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let viewController = UIStoryboard(name: "PPR", bundle: nil).instantiateViewController(withIdentifier: "PPRTasksController") as? PPRTasksController else {
            return
        }
        if isActive {
            viewController.titleText = activePPR[indexPath.row].title ?? ""
            viewController.taskID = activePPR[indexPath.row].id
            viewController.isStarted = activePPR[indexPath.row].worker != nil
            viewController.fromIsActive = true
        } else {
            viewController.titleText = inactivePPR[indexPath.row].maintenance?.title ?? ""
            viewController.taskID = inactivePPR[indexPath.row].maintenance?.id
            viewController.isStarted = inactivePPR[indexPath.row].maintenance?.worker != nil
            viewController.fromIsActive = false
            viewController.inactiveTasks = inactivePPR[indexPath.row].taskReports ?? []
        }
        
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // For Active pagination
        if isActive && indexPath.row == activePPR.count - 2 {
            if hesNextActivePage {
                loadActivePPR()
                }
            }
        // For Incative pagination
        if !isActive && indexPath.row == inactivePPR.count - 2 {
            if hesNextInactivePage {
                loadInactivePPR()
                }
            }
        }
}
