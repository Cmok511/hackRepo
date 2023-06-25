//
//  DetailInfoAboutPlotViewController.swift
//  hackathon
//
//  Created by iOS AXAS on 24.06.2023.
//

import UIKit

class DetailInfoAboutPlotViewController: UIViewController {

    @IBOutlet weak private var maintableView: UITableView!

    private var expandDescription: Bool = false
    private var descriptionLabelHeight: CGFloat = 150

    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var humidityLabel: UILabel!
    @IBOutlet weak private var stageLabel: UILabel!
    @IBOutlet weak private var variationsOfGrapeLabel: UILabel!
    @IBOutlet weak var squareLabel: UILabel!


    var data: GetLocationsResponseData?

    fileprivate enum Sections: Int, CaseIterable {
        case picture
        case briefInfo
        case description
        case promise
        case tasks
    }

    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    //MARK: return to prev viewController
    @IBAction private func returnButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    //MARK: setupUI
    private func setupUI() {
        maintableView.delegate = self
        maintableView.dataSource = self
    }
}

extension DetailInfoAboutPlotViewController: UITableViewDelegate {

}

extension DetailInfoAboutPlotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sections = Sections(rawValue: indexPath.row)
        switch sections {
        case .picture:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureTableViewCell") as! PictureTableViewCell
            return cell
        case .briefInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BriefInfoTableViewCell") as! BriefInfoTableViewCell
            cell.data = data
            return cell
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTableViewCell") as! DescriptionTableViewCell
            cell.delegate = self
            return cell
        case .promise:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PromiseTableViewCell") as! PromiseTableViewCell
            return cell
        case .tasks:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskFromPlotTableViewCell") as! TasksFromPlotTableViewCell
            return cell
        default:
            return UITableViewCell()
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sections = Sections(rawValue: indexPath.row)
        switch sections {
        case .picture:
            return 290
        case .briefInfo:
            return 215
        case .description:
            if !expandDescription {
                return 135
            } else {
                return descriptionLabelHeight + 60
            }
        case .promise:
            return 215
        case .tasks:
            return 215
        default:
            return 50
        }
    }
}

extension DetailInfoAboutPlotViewController: DescriptionTableViewCellDelegate {
    func sendChangeRowHeight() {
        expandDescription.toggle()
        UIView.animate(withDuration: 2, animations: { [self] in
            if expandDescription {
                descriptionLabelHeight = 150
            } else {
                descriptionLabelHeight = 58
            }
            view.layoutIfNeeded()
        })

        maintableView.reloadData()
    }
}
