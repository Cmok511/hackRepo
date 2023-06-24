//
//  TaskListController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 07.03.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import LoadingShimmer

final class TaskListController: UIViewController {
    
    @IBOutlet weak private var activeButton: UIButton!
    @IBOutlet weak private var activeBorder: UIView!
    @IBOutlet weak private var finishedButton: UIButton!
    @IBOutlet weak private var finishedBorder: UIView!
    @IBOutlet weak private var taskTable: UITableView!
    @IBOutlet weak private var mockview: UIStackView!
    @IBOutlet weak private var spinner: UIActivityIndicatorView!
    //pagination
    private var activePage = 1
    private var inactivePage = 1
    private var hasNextActivePage = false
    private var hasNextInactivePage = false
    
    
    private var isActive = true
    
    private var taskList: [WorkTask?] = [] {
        didSet {
            taskTable.reloadData()
        }
    }
    private var refreshControl = UIRefreshControl()
    private var selectedTask: WorkTask?

//MARK:  lifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTaskList()
    }
    
    private func setupUI() {
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните вниз чтобы обновить")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        taskTable.addSubview(refreshControl)
        
        activeBorder.isHidden = false
        finishedBorder.isHidden = true
        activeButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        mockview.isHidden = true
    }
    
    
    //MARK: REFERSH TABLE
    @objc private func refreshData() {
        getTaskList()
        viewWillAppear(true)
        activePage = 1
        inactivePage = 1
        spinner.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    
    //MARK: SHOW ACTIVE
    @IBAction private func showActive(_ sender: UIButton) {
        activeButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        activeBorder.isHidden = false
        finishedBorder.isHidden = true
        taskList = []
        getTaskList()
        activePage = 1
    }
    
    //MARK: SHOW FINISHED
    @IBAction private func showFinished(_ sender: UIButton) {
        activeButton.setTitleColor(UIColor(named: "GreyBorder"), for: .normal)
        finishedButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        activeBorder.isHidden = true
        finishedBorder.isHidden = false
        taskList = []
        getTaskList()
        inactivePage = 1
    }
    
    
    //MARK: GET TASK LIST
    private func getTaskList() {
        spinner.startAnimating()
        let page = finishedBorder.isHidden ? activePage : inactivePage
        isActive = finishedBorder.isHidden
       
        firstly{
            TaskModel.fetchTaskList(isActive: self.isActive, page: page)
        }.done { [weak self] data in
            guard let self else { return }
            // if statusCode == 200
            if (data.message.lowercased() == "ok") {
                taskList = page == 1 ? data.data : taskList + data.data
                mockview.isHidden = !data.data.isEmpty
                if isActive {
                hasNextActivePage = data.meta?.pagination?.hasNext ?? false
                activePage = hasNextActivePage ? activePage + 1 : activePage
                } else {
                hasNextInactivePage = data.meta?.pagination?.hasNext ?? false
                inactivePage = hasNextInactivePage ? inactivePage + 1 : inactivePage
                }
            } else {
                view.makeToast("Не удалось получить список задач. Обратитесь к администратору сервиса")
            }
            spinner.stopAnimating()
        }.catch{ [weak self] error in
            guard let self else { return }
            view.makeToast("Что-то пошло не так")
            spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTask" {
            let destinationVC = segue.destination as! OneTaskController
            destinationVC.workTask = selectedTask
        }
    }
}


//MARK: - UITableViewDataSource

extension TaskListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        taskCell.configure(task: taskList[indexPath.row], isActive: isActive)
        return taskCell
    }
}
//MARK: - UITableViewDelegate

extension TaskListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTask = taskList[indexPath.row]
        performSegue(withIdentifier: "showTask", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == taskList.count - 2 {
            //for active tasks
            if self.isActive && hasNextActivePage {
                getTaskList()
            }
            //for inactive tasks
            if !self.isActive && hasNextInactivePage {
                getTaskList()
            }
        }
    }
}
    
