//
//  OneTaskController.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 11.03.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import SDWebImage

enum OneTaskControllerState {
    case task
    case isTour
    case isPPR
    case fromInactiteTour
    case fromInactitePPR
}

final class OneTaskController: UIViewController {
    
    @IBOutlet weak private var taskIdLabel: UILabel!
    @IBOutlet weak private var name: UILabel!
    @IBOutlet weak private var taskDescription: UILabel!
    @IBOutlet weak private var deadline: UILabel!
    @IBOutlet weak private var creatorName: UILabel!
    @IBOutlet weak private var locationLabel: UILabel!
    @IBOutlet weak private var taskImageCollection: UICollectionView!
    @IBOutlet weak private var reportImageCollection: UICollectionView!
    @IBOutlet weak private var reportTF: UITextView!
    @IBOutlet weak private var spinner: UIActivityIndicatorView!
    @IBOutlet weak private var buttonsStack: UIStackView!
    @IBOutlet weak private var startTaskButton: UIButton!
    @IBOutlet weak private var completeButton: UIButton!
    @IBOutlet weak private var rejectButton: UIButton!
    @IBOutlet weak private var categotyLabel: UILabel!
    @IBOutlet weak private var returnedView: UIView!
    @IBOutlet weak private var commentOfReturn: UILabel!
    @IBOutlet weak private var buttonsView: UIView!
    
    private var taskIsComplited: Bool = false {
        didSet {
            buttonsView.isHidden = taskIsComplited
            reportTF.isUserInteractionEnabled = false
        }
    }
    
   private var reportImagesData: [Data?] = []

    var workTask: WorkTask?
    var pprTask: MaintenanceTask?
    
    var inactiveToursReports: TourTaskReports?
    var inactivePPRReports: WorkTaskReports?
    
    var state : OneTaskControllerState = .task
    
    //MARK: - lifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI()
    }
    
    private func setupUI() {
        reportTF.sizeToFit()
        reportImageCollection.delegate = self
        taskImageCollection.delegate = self
        taskImageCollection.dataSource = self
        reportImageCollection.delegate = self
        reportImageCollection.dataSource = self
        rejectButton.blueBorder()
        rejectButton.addRadius()
        completeButton.addRadius()
        startTaskButton.blueBorder()
        startTaskButton.addRadius()
    }
    
    private func configureUI() {
        // была ли заявка возвращена
        if workTask?.returnedCount ?? 0 > 0 {
            returnedView.isHidden = false
            commentOfReturn.text = workTask?.comment ?? ""
        }
        
        switch state {
        case .fromInactiteTour :
            taskIsComplited = true
            taskIdLabel.text =  "№ \(inactiveToursReports?.task.id ?? 0)"
            name.text = inactiveToursReports?.task.title
            deadline.text = inactiveToursReports?.task.deadline?.toDay
            taskDescription.text = inactiveToursReports?.task.description
            creatorName.text = (inactiveToursReports?.creator?.lastName ?? "") + " " + (inactiveToursReports?.creator?.firstName ?? "")
            categotyLabel.text = inactiveToursReports?.task.worker?.group?.name ?? "Нет категории"
            locationLabel.text = (inactiveToursReports?.task.location?.address?.name ?? "") + " " + (workTask?.location?.description ?? "")
            reportTF.text = inactiveToursReports?.comment
            
        case .isPPR :
            taskIsComplited = (pprTask?.status ?? 0) == 3
            taskIdLabel.text = "№\(pprTask?.id ?? 0)"
            name.text = pprTask?.title ?? ""
            taskDescription.text = pprTask?.description ?? ""
            deadline.text = pprTask?.deadline?.toDayAndHour
            creatorName.text = (pprTask?.creator?.lastName ?? "") + " " + (pprTask?.creator?.firstName ?? "")
            categotyLabel.text = pprTask?.worker?.group?.name
            locationLabel.text = (pprTask?.location?.address?.name ?? "") + " " + (pprTask?.location?.description ?? "")
            
            if pprTask?.status == 2 {
                buttonsStack.isHidden = false
                startTaskButton.isHidden = true
            } else {
                buttonsStack.isHidden = true
                startTaskButton.isHidden = false
            }
            
        case .fromInactitePPR :
            taskIsComplited = true
            taskIdLabel.text =  "№ \(inactivePPRReports?.task?.id ?? 0)"
            name.text = inactivePPRReports?.task?.title
            deadline.text = inactivePPRReports?.task?.deadline?.toDay
            taskDescription.text = inactivePPRReports?.task?.description
            creatorName.text = (inactivePPRReports?.creator?.lastName ?? "") + " " + (inactivePPRReports?.creator?.firstName ?? "")
            categotyLabel.text = inactivePPRReports?.task?.worker?.group?.name ?? "Нет категории"
            locationLabel.text = (inactivePPRReports?.task?.location?.address?.name ?? "") + " " + (workTask?.location?.description ?? "")
            reportTF.text = inactivePPRReports?.comment
            
        default:
            taskIsComplited = (workTask?.status ?? 0) == 3
            taskIdLabel.text = "№\(workTask?.id ?? 0)"
            name.text = workTask?.title ?? ""
            taskDescription.text = workTask?.description ?? ""
            deadline.text = workTask?.deadline?.toDayAndHour
            creatorName.text = (workTask?.creator?.lastName ?? "") + " " + (workTask?.creator?.firstName ?? "")
            categotyLabel.text = workTask?.worker?.group?.name ?? "Нет категории"
            locationLabel.text = (workTask?.location?.address?.name ?? "") + " " + (workTask?.location?.description ?? "")
            if taskIsComplited {
                reportTF.text = workTask?.comment
            }
        }
        
        if state != .isPPR {
            if workTask?.status == 2 {
                buttonsStack.isHidden = false
                startTaskButton.isHidden = true
            } else {
                buttonsStack.isHidden = true
                startTaskButton.isHidden = false
            }
        }
    }
    
    @IBAction private func close(_ sender: UIButton){
        dismiss(animated: true)
    }
    
    //MARK: TAP START TASK BUTTON
    @IBAction func startTask(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "isStartWork") == false {
            let startWorkAlert = UIAlertController(title: "Внимание", message: "Для того чтобы приступить к задаче необходимо начать рабочий день. Начать сейчас?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                UserDefaults.standard.set(true, forKey: "isStartWork")
                guard let self else { return }
                
                switch state {
                case .isPPR :
                    self.startPPRTask()
                    print("isPPR")
                    
                case .isTour :
                    self.startTourTask()
                    print("isisTour")
                    
                default :
                    self.startTask()
                    print("isTask")
                }
            }
            let cancelAction = UIAlertAction(title: "Нет", style: .destructive)
            startWorkAlert.addAction(okAction)
            startWorkAlert.addAction(cancelAction)
            present(startWorkAlert, animated: true)
        } else {
            state == .isTour ? self.startTourTask() : self.startTask()
        }
    }
    
    //MARK: START TASK ON SERVER
    func startTask() {
        spinner.startAnimating()
        firstly{
            TaskModel.startTask(taskId: workTask?.id ?? 0)
        }.done { [weak self] data in
            guard let self else { return }
            // if ok
            if (data.message.lowercased() == "ok") {
                spinner.stopAnimating()
                view.makeToast("Начато выполнение задачи")
                buttonsStack.isHidden = false
                startTaskButton.isHidden = true
                workTask = data.data
            } else {
                spinner.stopAnimating()
            }
        }.catch { [weak self] error in
            self?.spinner.stopAnimating()
            print(error.localizedDescription)
        }
    }
    //MARK: START TOUR ON SERVER
    func startTourTask() {
        guard let tourID = workTask?.id else {return}
        spinner.startAnimating()
        firstly {
            TaskModel.startTour(tourID: tourID)
        }.done { data in
            if data.message?.lowercased() == "ok" {
                self.view.makeToast("Обход начат", duration: 0.5)
                self.spinner.stopAnimating()
                self.view.makeToast("Начато выполнение задачи")
                self.buttonsStack.isHidden = false
                self.startTaskButton.isHidden = true
                self.workTask = data.data
            } else  {
                self.view.makeToast(data.description)
            }
            self.spinner.stopAnimating()
        }.catch { error in
            print(error)
            self.spinner.stopAnimating()
        }
    }
    //MARK: START PPR ON SERVER
    func startPPRTask() {
        guard let ppdTaskID = pprTask?.id else {return}
        spinner.startAnimating()
        firstly {
            TaskModel.startPPRTask(pprTaskID: ppdTaskID)
        }.done { [weak self] data in
            guard let self else { return }
            if data.message?.lowercased() == "ok" {
                view.makeToast("Обход начат", duration: 0.5)
                spinner.stopAnimating()
                view.makeToast("Начато выполнение задачи")
                buttonsStack.isHidden = false
                startTaskButton.isHidden = true
                pprTask = data.data
            } else  {
                view.makeToast(data.description)
            }
            spinner.stopAnimating()
        }.catch { [weak self] error in
            print(error)
            self?.spinner.stopAnimating()
        }
    }
    
    private func sendTourTaskReport(index: Int) {
        var imageIDs: [Int] = []
        // тег кнопки в сториборд для выполнить 1, для отклонить 0
        let isComplite = index == 1
        print(isComplite)
        if reportTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Укажите текст отчета")
            return
        }
        spinner.startAnimating()
        let semaphore = DispatchSemaphore(value: 1)
        let queue = DispatchQueue(label: "queue")
        if !reportImagesData.isEmpty {
            let group = DispatchGroup()
            semaphore.wait()
            queue.async {
                for image in self.reportImagesData {
                    group.enter()
                    firstly {
                        TaskModel.putTourImage(image: image)
                    }.done { data in
                        if data.message?.lowercased() == "ok" {
                            imageIDs.append(data.data.id!)
                        }
                        group.leave()
                    }.catch { error in
                        print(error)
                        group.leave()
                    }
                    group.notify(queue: .main) {
                        semaphore.signal()
                    }
                }
            }
        }
        queue.async {
            semaphore.wait()
            DispatchQueue.main.async {
                firstly{
                    TaskModel.createTourTaskReport(taskId: self.workTask?.id ?? 0, report: self.reportTF.text ?? "", isComplite: isComplite, photosID: imageIDs)
                }.done { [weak self] data in
                    // if ok
                    if (data.message.lowercased() == "ok") {
                        self?.spinner.stopAnimating()
                        if isComplite {
                            self?.view.makeToast("Отчёт успешно отправлен")
                        } else  {
                            self?.view.makeToast("Задача отменена")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                            self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        })
                        self?.buttonsStack.isHidden = false
                        self?.startTaskButton.isHidden = true
                    } else {
                        self?.spinner.stopAnimating()
                    }
                }.catch{ [weak self] error in
                    self?.spinner.stopAnimating()
                    print(error.localizedDescription)
                }
            }
            semaphore.signal()
        }
    }
    private func sendTaskReport(index: Int) {
        var imageIDs: [Int] = []
        // тег кнопки в сториборд для выполнить 1, для отклонить 0
        let isComplite = index == 1
        if reportTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Укажите текст отчета")
            return
        }
        spinner.startAnimating()
        let semaphore = DispatchSemaphore(value: 1)
        let queue = DispatchQueue(label: "queue")
        if !reportImagesData.isEmpty {
            let group = DispatchGroup()
            semaphore.wait()
            queue.async {
                for image in self.reportImagesData {
                    group.enter()
                        firstly {
                            TaskModel.putImage(image: image)
                        }.done { data in
                            if data.message?.lowercased() == "ok" {
                                imageIDs.append(data.data.id!)
                            }
                            group.leave()
                        }.catch { error in
                            print(error)
                            group.leave()
                        }
                        group.notify(queue: .main) {
                            semaphore.signal()
                        }
                }
            }
        }
        queue.async {
            semaphore.wait()
            DispatchQueue.main.async {
                firstly{
                    TaskModel.createReport(taskId: self.workTask?.id ?? 0, report: self.reportTF.text ?? "", isComplite: isComplite, photosID: imageIDs)
                }.done { [weak self] data in
                    // if ok
                    if (data.message.lowercased() == "ok") {
                        self?.spinner.stopAnimating()
                        if isComplite {
                            self?.view.makeToast("Отчёт успешно отправлен")
                        } else  {
                            self?.view.makeToast("Задача отменена")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                            self?.dismiss(animated: true)
                        })
                        self?.buttonsStack.isHidden = false
                        self?.startTaskButton.isHidden = true
                    } else {
                        self?.spinner.stopAnimating()
                    }
                }.catch{ [weak self] error in
                    self?.spinner.stopAnimating()
                    print(error.localizedDescription)
                }
            }
            semaphore.signal()
        }
    }
    private func sendTaskPPRReport(tag: Int) {
        var imageIDs: [Int] = []
        // тег кнопки в сториборд для выполнить 1, для отклонить 0
        let isComplite = tag == 1
        print(isComplite)
        if reportTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("Укажите текст отчета")
            return
        }
        spinner.startAnimating()
        let semaphore = DispatchSemaphore(value: 1)
        let queue = DispatchQueue(label: "queue")
        if !reportImagesData.isEmpty {
            let group = DispatchGroup()
            semaphore.wait()
            queue.async {
                for image in self.reportImagesData {
                    group.enter()
                        firstly {
                            TaskModel.putPPRImage(image: image)
                        }.done { data in
                            if data.message?.lowercased() == "ok" {
                                imageIDs.append(data.data.id!)
                            }
                            group.leave()
                        }.catch { error in
                            print(error)
                            group.leave()
                        }
                        group.notify(queue: .main) {
                            semaphore.signal()
                        }
                }
            }
        }
        queue.async {
            semaphore.wait()
            DispatchQueue.main.async {
                firstly{
                    TaskModel.createPPRTaskReport(pprTaskId: self.pprTask?.id ?? 0, report: self.reportTF.text ?? "", isComplite: isComplite, photosID: imageIDs)
                    
                }.done { [weak self] data in
                    // if ok
                    if (data.message?.lowercased() == "ok") {
                        self?.spinner.stopAnimating()
                        if isComplite {
                            self?.view.makeToast("Отчёт успешно отправлен")
                        } else  {
                            self?.view.makeToast("Задача отменена")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                            self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        })
                        self?.buttonsStack.isHidden = false
                        self?.startTaskButton.isHidden = true
                    } else {
                        self?.spinner.stopAnimating()
                    }
                }.catch{ [weak self] error in
                    self?.spinner.stopAnimating()
                    print(error.localizedDescription)
                }
            }
            semaphore.signal()
        }
        
        
        
        
    }
    
    //MARK: CRATE REPORT
    @IBAction func createReport(_ sender: UIButton) {
        switch state {
        case .isTour:
            sendTourTaskReport(index: sender.tag)
        case .isPPR:
            sendTaskPPRReport(tag: sender.tag)
        default :
            sendTaskReport(index: sender.tag)
        }
    }
}

//MARK: WORK WITH IMAGE
extension OneTaskController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: AVATAR ALERT CONTROLLER
    @objc func addPhoto() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // select Camera
        let camera = UIAlertAction(title: "Снять фото", style: .default) { _ in
            self.chooseImagePicker(source: UIImagePickerController.SourceType.camera)
        }
        // select Gallery
        let photo = UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
            self.chooseImagePicker(source: UIImagePickerController.SourceType.photoLibrary)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true)
    }
    
    @objc func deletePhoto(_ sender: UIButton){
        reportImagesData.remove(at: sender.tag)
        reportImageCollection.reloadData()
    }
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        reportImagesData.append((info[.editedImage] as? UIImage)?.jpegData(compressionQuality: 0.5))
        picker.dismiss(animated: true)
        reportImageCollection.reloadData()
    }
}

//MARK: - UICollectionViewDataSource

extension OneTaskController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // taskImageCollection
        if collectionView == taskImageCollection {
            
            switch state {
            case .fromInactiteTour :
                return inactiveToursReports?.task.photos.count ?? 0
            case .fromInactitePPR :
                return inactivePPRReports?.task?.photos.count ?? 0
            default :
                return workTask?.photos.count ?? 0
            }
            
        }
        // reportImageCollection
        if collectionView == reportImageCollection {
            if !taskIsComplited {
                if reportImagesData.count == 5 {
                    return 5
                } else {
                    return reportImagesData.count + 1
                }
            } else { // taskIsComplited
                switch state {
                case .fromInactiteTour :
                    return inactiveToursReports?.photos?.count ?? 0
                case .fromInactitePPR:
                    return inactivePPRReports?.photos?.count ?? 0
                default :
                    return workTask?.report?.photos.count ?? 0
                }
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! TaskImageCollectionViewCell
        
        // taskImageCollection
        if collectionView == taskImageCollection {
            imageCell.deleteButton.isHidden = true
            switch state {
            case .fromInactiteTour:
                imageCell.image.sd_setImage(with:  URL(string: inactiveToursReports?.task.photos[indexPath.item]?.url ?? ""))
            case .fromInactitePPR:
                imageCell.image.sd_setImage(with:  URL(string: inactivePPRReports?.task?.photos[indexPath.item]?.url ?? "" ))
            default:
                imageCell.image.sd_setImage(with: URL(string: workTask?.photos[indexPath.row]?.url ?? ""))
            }
        }
       
        // reportImageCollection
        if collectionView == reportImageCollection {
            imageCell.deleteButton.isHidden = taskIsComplited
            
            if !taskIsComplited {
                let tap = UITapGestureRecognizer(target: self, action: #selector(addPhoto))
                imageCell.deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
                if indexPath.item == reportImagesData.count {
                    imageCell.image.image = UIImage(named: "AddImage")
                    imageCell.deleteButton.isHidden = true
                    imageCell.addGestureRecognizer(tap)
                } else {
                    imageCell.image.image = UIImage(data: reportImagesData[indexPath.item]!)
                    imageCell.deleteButton.isHidden = false
                    imageCell.deleteButton.tag = indexPath.row
                    for recognizer in imageCell.gestureRecognizers ?? []{
                        imageCell.removeGestureRecognizer(recognizer)
                    }
                }
                return imageCell
            }
            if taskIsComplited {
                switch state {
                case .fromInactiteTour :
                    imageCell.image.sd_setImage(with: URL(string: inactiveToursReports?.photos?[indexPath.row].url ?? ""))
                    
                case .fromInactitePPR :
                    imageCell.image.sd_setImage(with: URL(string: inactivePPRReports?.photos?[indexPath.row].url ?? ""))
                default :
                    imageCell.image.sd_setImage(with: URL(string: workTask?.report?.photos[indexPath.row]?.url ?? ""))
                }
                return imageCell
            }
        }
       
        return imageCell
    }
}
//MARK: - UICollectionViewDelegate

extension OneTaskController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let controller = UIStoryboard(name: "Tasks",
                                                bundle:nil)
            .instantiateViewController(withIdentifier: "PhotoFullScreenController")
                as? PhotoFullScreenController
        else { return }
        
        // reportImageCollection
        if collectionView == reportImageCollection {
            if taskIsComplited {
                switch state {
                case .fromInactiteTour:
                    let image = inactiveToursReports?.photos?[indexPath.item]
                    controller.image = image
                case .fromInactitePPR:
                    let image = inactivePPRReports?.photos?[indexPath.item]
                    controller.image = image
                default :
                    let image = workTask?.report?.photos[indexPath.item]
                    controller.image = image
                }
            } else {
                let image = workTask?.photos[indexPath.item]
                controller.image = image
            }
        }
        
        // taskImageCollection
        if collectionView == taskImageCollection {
            switch state {
            case .fromInactiteTour:
                let image = inactiveToursReports?.task.photos[indexPath.item]
                controller.image = image
            case .fromInactitePPR:
                let image = inactivePPRReports?.task?.photos[indexPath.item]
                controller.image = image
            default :
                let image = workTask?.photos[indexPath.item]
                controller.image = image
            }
        }
        
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
}
