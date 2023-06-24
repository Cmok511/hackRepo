//
//  DetourTableViewCell.swift
//  QRInspect
//
//

import Foundation
import UIKit

final class DetourTableViewCell: UITableViewCell {
    static let reuseID = "DetourTableViewCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taskCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeBackView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(tour: GettingTour) {
        titleLabel.text = tour.title
        timeLabel.textColor = .white
        timeBackView.backgroundColor = UIColor(named: "AccentColor")
        taskCountLabel.isHidden = false
        taskCountLabel.text = "\(tour.tasks?.count ?? 0)"
        timeLabel.text = "до " + (tour.planned?.toDayAndHour ?? "")
        var repeatLabel = ""
        switch tour.repeatUnit {
        case 0: repeatLabel = "Единоразово"
        case 1: repeatLabel = "Ежедневно"
        case 2: repeatLabel = "Еженедельно"
        case 3: repeatLabel = "Ежемесячно"
        default: repeatLabel = ""
        }
        dateLabel.text = repeatLabel
        //"Один раз в \(repeatVAlue) \(repeatUnit)"
        
    }
    
    func configure(tour: InactiveToursData) {
        titleLabel.text = tour.tour?.title
        taskCountLabel.text = "\(tour.taskReports?.count ?? 0)"
        timeLabel.text = "Завершено"
        timeLabel.textColor = UIColor(named: "AccentColor")
        timeBackView.backgroundColor = .white
        
        var repeatLabel = ""
        switch tour.tour?.repeatUnit {
        case 0: repeatLabel = "Единоразово"
        case 1: repeatLabel = "Ежедневно"
        case 2: repeatLabel = "Еженедельно"
        case 3: repeatLabel = "Ежемесячно"
        default: repeatLabel = ""
        }
        dateLabel.text = repeatLabel
        //"Один раз в \(repeatVAlue) \(repeatUnit)"
    }
}
