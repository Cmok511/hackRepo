//
//  PPRTableViewCell.swift
//  QRInspect
//
//  Created by Денис Чупров on 24.06.2023.
//

import Foundation
import UIKit

final class PPRTableViewCell: UITableViewCell {
    static let reuseID = "PPRTableViewCell"
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var taskCountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var timeBackView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(maintenance: Maintenance) {
        timeLabel.textColor = .white
        timeBackView.backgroundColor = UIColor(named: "AccentColor")
        titleLabel.text = maintenance.title
       
        
        taskCountLabel.text = "\(maintenance.tasks.count)"
        timeLabel.text = maintenance.planned?.toDayAndHour
        
        var repeatLabel = ""
        switch maintenance.repeatUnit {
        case 0: repeatLabel = "Единоразово"
        case 1: repeatLabel = "Ежедневно"
        case 2: repeatLabel = "Еженедельно"
        case 3: repeatLabel = "Ежемесячно"
        default: repeatLabel = ""
        }
        dateLabel.text = repeatLabel
    }
    
    func configure(inactivePPR: InactivePPR) {
        titleLabel.text = inactivePPR.maintenance?.title
        //Симантика
        taskCountLabel.text = "\(inactivePPR.taskReports?.count ?? 0)"
        timeLabel.text = "Завершено"
        timeLabel.textColor = UIColor(named: "AccentColor")
        timeBackView.backgroundColor = .white
        
        var repeatLabel = ""
        switch inactivePPR.maintenance?.repeatUnit {
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
