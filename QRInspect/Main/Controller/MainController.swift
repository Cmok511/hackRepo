//
//  MainController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit
import SDWebImage
import PromiseKit
import Toast_Swift

final class MainController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var avatar: UIImageView!
    @IBOutlet weak private var professionCategory: UILabel!
    @IBOutlet weak private var profession: UILabel!
    @IBOutlet weak private var centralView: UIView!
    
    private var recomendationArray: [GettingRecomendation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var locationsArray: [GettingLocation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var urgentTasks: [WorkTask?] = [] {
        didSet {
            tableView.reloadData()
        }
    }
   
    //MARK: data from API
    private var temperature: Int = 0
    private var humidity: Int = 0
    private var prediction: String = ""
    private var dateOfWeather: Int = 0

    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getWeather()
        fetchLocations()
        fetchRecomendation()
    }
    
    //MARK: fetch recomendation from API
    private func fetchRecomendation() {
        firstly {
            MainModel.getRecomendation()
        }.done { data in
            if data.message?.lowercased() == "ok" {
                self.recomendationArray = data.data ?? []
            } else {
                self.view.makeToast(data.description)
            }
        }.catch { error in
            self.view.makeToast("ЧТо-то пошло не так")
            print(error.localizedDescription)
        }
    }

    //MARK: get locations from API
    private func fetchLocations() {
        firstly {
            MainModel.getLocations()
        }.done { data in
            if data.message?.lowercased() == "ok" {
                self.locationsArray = data.data ?? []
                self.tableView.reloadData()
            } else {
                self.view.makeToast(data.description)
            }
        }.catch { error in
            self.view.makeToast("Что-то пошло не так")
            print(error.localizedDescription)
        }
    }

    //MARK: get tasks by urgent from API
    private func getUrgentTasks() {
        firstly {
            MainModel.getTasks()
        }.done { data in
            if data.message?.lowercased() == "ok" {
                self.urgentTasks = data.data ?? []
            } else {
                self.view.makeToast(data.description)
            }
        }.catch { error in
            self.view.makeToast("Что-то пошло не так")
            print(error.localizedDescription)
        }
    }

    //MARK: get weather from API
    private func getWeather() {
        firstly(execute: {
            MainModel.getWeather(lat: 44.539779, lon: 38.083293)
        }).done({ data in
            if data.message?.lowercased() == "ok" {
                self.humidity = data.data?.humidity ?? 0
                self.prediction = data.data?.prediction ?? ""
                self.temperature = data.data?.temperature ?? 0
                self.dateOfWeather = data.data?.now ?? 0
                self.tableView.reloadData()
            }
        }).catch {  error in
            self.view.makeToast("Something went wrong...")
        }
    }

    //MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAvatar()
        tableView.dataSource = self
        getUrgentTasks()
    }

    //MARK: setupUI
    private func setupUI() {
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goProfile)))
   
        avatar.setOval()
        centralView.topRadius()
        profession.text = "\(getProfile().firstName ?? "") \(getProfile().lastName ?? "") \(getProfile().patronymic ?? "")"
        professionCategory.text = getProfile().group?.name
       
        tableView.dataSource = self
        tableView.delegate = self
    }

    //MARK: load avatar from API
    private func loadAvatar() {
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if getProfile().avatar == nil {
            avatar.image = UIImage(named: "agronomLogo")
        } else {
            avatar.sd_setImage(with: URL(string: getProfile()?.avatar ?? ""), placeholderImage: UIImage(named: "AvatarBlack"), options: [], context: [:])
        }
    }

    //MARK: change controller to profile
    @objc private func goProfile(_ sender: Any){
        performSegue(withIdentifier: "goProfile", sender: nil)
    }
}

//MARK: - UITableViewDataSource
extension MainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 110
        case 1:
            return 175
        case 2:
            return 185
        case 3:
            return 185
        default:
            return 1000
        }
    }
}

//MARK: - UITableViewDataSource
extension MainController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0 :
            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.reuseID) as! WeatherTableViewCell
            cell.configure(temp: self.temperature,
                           humidity: self.humidity,
                           dateOfWather: self.dateOfWeather,
                           predicate: self.prediction)
            return cell
        case 1 :
            let cell = tableView.dequeueReusableCell(withIdentifier: LocationsTableViewCell.ruuseID) as! LocationsTableViewCell
            cell.delegate = self
            cell.configure(locationsArray)
            return cell
        case 2 :
            let cell = tableView.dequeueReusableCell(withIdentifier: ReconendationsTableViewCell.reuseID) as! ReconendationsTableViewCell
            cell.configure(recomendationArray)
            return cell
        case 3 :
            let cell = tableView.dequeueReusableCell(withIdentifier: TasksTableViewCell.reuseID) as! TasksTableViewCell
            cell.delegete = self
            cell.configure(urgentTasks)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
//MARK: - LocationsTableViewCellDelegate
extension MainController: LocationsTableViewCellDelegate {
    func selectLocation(_ value: Int) {
        guard let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "DetailInfoAboutPlotViewController") as? DetailInfoAboutPlotViewController else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
}
//MARK: - TasksTableViewCellDelegate
extension MainController: TasksTableViewCellDelegate {
    func selectTask(value: Int) {
        guard let viewController = UIStoryboard(name: "Tasks", bundle: nil).instantiateViewController(withIdentifier: "OneTaskController") as? OneTaskController else {
            return
        }
        viewController.workTask = urgentTasks[value]
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
    
}

