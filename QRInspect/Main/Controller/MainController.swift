//
//  MainController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 07.03.2023.
//

import UIKit
import SDWebImage
import PromiseKit
import Toast_Swift

final class MainController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak private var avatar: UIImageView!
    @IBOutlet weak private var professionCategory: UILabel!
    @IBOutlet weak private var profession: UILabel!
    @IBOutlet weak private var centralView: UIView!
    @IBOutlet weak private var spinner: UIActivityIndicatorView!
    
    @IBOutlet private weak var locationcollectionView: UICollectionView!
    @IBOutlet private weak var reconendationCollectionView: UICollectionView!
    @IBOutlet private weak var tasksCollectionView: UICollectionView!
    
    //temperature
    @IBOutlet weak var dateOfWather: UILabel!
    @IBOutlet weak var temperatureofWether: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var filsLikeLabel: UILabel!
    @IBOutlet weak var weatherLogo: UIImageView!

    private var recomendationArray: [GettingRecomendation] = [] {
        didSet {
            reconendationCollectionView.reloadData()
        }
    }
    private var locationsArray: [GettingLocation] = [] {
        didSet {
            locationcollectionView.reloadData()
        }
    }
    private var urgentTasks: [WorkTask?] = [] {
        didSet {
            tasksCollectionView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        fetchRecomendation()
        fetchLocations()
        getUrgentTasks()
        getWeather()
    }
    
    //MARK:  fetchRecomendation
    
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
    
    private func fetchLocations() {
        firstly {
            MainModel.getLocations()
        }.done { data in
            if data.message?.lowercased() == "ok" {
                self.locationsArray = data.data ?? []
            } else {
                self.view.makeToast(data.description)
            }
        }.catch { error in
            self.view.makeToast("Что-то пошло не так")
            print(error.localizedDescription)
        }
    }
    
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
    
    private func getWeather() {
        firstly(execute: {
            MainModel.getWeather(lat: 44.539779, lon: 38.083293)
        }).done({ data in
            if data.message?.lowercased() == "ok" {
              //  self.dateOfWather.text = Date().timeIntervalSinceNow
                self.temperatureofWether.text = "\(data.data?.temperature ?? 0) °C"
                self.humidity.text = "\(data.data?.humidity ?? 0) %"
                self.filsLikeLabel.text = data.data?.prediction
            }
        }).catch {  error in
            self.view.makeToast("Something went wrong...")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAvatar()
        settingsUI()
    }
    
    private func setupUI() {
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goProfile)))
   
        avatar.setOval()
        centralView.topRadius()
        profession.text = (getProfile().firstName ?? "") + (getProfile().lastName ?? "") + (getProfile().patronymic ?? "")
        professionCategory.text = "Агроном"
       
        locationcollectionView.dataSource = self
        locationcollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        reconendationCollectionView.dataSource = self
        reconendationCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tasksCollectionView.dataSource = self
        tasksCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func settingsUI() {
        
    
    }
    
    private func loadAvatar() {
        spinner.stopAnimating()
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatar.sd_setImage(with: URL(string: getProfile()?.avatar ?? ""), placeholderImage: UIImage(named: "AvatarBlack"), options: [], context: [:])
    }
    

    //MARK: GO PROFILE
    @objc private func goProfile(_ sender: Any){
        performSegue(withIdentifier: "goProfile", sender: nil)
    }
    
    //MARK: GO QR
    @objc private func scanQR(_ sender: Any){
        performSegue(withIdentifier: "goQR", sender: nil)
    }
    
    //MARK: GO SCHEDULE
    @objc private func goSchedule(_ sender: Any){
        performSegue(withIdentifier: "goSchedule", sender: nil)
    }
    
    //MARK: GO TASK
    @objc private func goTask(_ sender: Any){
        tabBarController?.selectedIndex = 1
    }
    
    // MARK: START/END WORK
    @IBAction private func startEndWork() {
        spinner.startAnimating()
        firstly{
            MainModel.workStartEnd(isStart: !(UserDefaults.standard.bool(forKey: "isStartWork")))
        }.done { [weak self] data in
            // if ok
            if (data.message.lowercased() == "ok") {
                self?.spinner.stopAnimating()
                UserDefaults.standard.set(!(UserDefaults.standard.bool(forKey: "isStartWork")), forKey: "isStartWork")
                if UserDefaults.standard.bool(forKey: "isStartWork") == true {
                    self?.view.makeToast("Рабочий день успешно начат")
                } else {
                    self?.view.makeToast("Рабочий день успешно завершён")
                }
            } else {
                self?.spinner.stopAnimating()
            }
        }.catch{ [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension MainController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case locationcollectionView:
            return locationsArray.count
        case reconendationCollectionView:
            return recomendationArray.count
        case tasksCollectionView:
            return urgentTasks.count
        default :
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case locationcollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationColectionViewCell.reuseID, for: indexPath) as! LocationColectionViewCell
            cell.configure(locationsArray[indexPath.item])
            return cell
            
        case reconendationCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReconendationCollectionViewCell.reuseID, for: indexPath) as! ReconendationCollectionViewCell
            cell.configure(recomendationArray[indexPath.item])
            return cell
            
        case tasksCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCollectionViewCell.reuseID, for: indexPath) as! TaskCollectionViewCell
            cell.configure(task: urgentTasks[indexPath.item], isActive: true)
            return cell
        default :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReconendationCollectionViewCell.reuseID, for: indexPath) as! ReconendationCollectionViewCell
            return cell
        }
        
        
    }
}
