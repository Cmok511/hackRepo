//
//  DetourTaskTableViewCell.swift
//  QRInspect
//
//

import Foundation
import UIKit

final class DetourTaskTableViewCell: UITableViewCell {
    static let reuseID = "DetourTaskTableViewCell"
    @IBOutlet private weak var tittleLabel: UILabel!
    @IBOutlet private weak var statusImage: UIImageView!
    @IBOutlet weak var qrButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configure(task: WorkTask) {
        switch task.status {
            //Отклонено
        case 1 : statusImage.image = UIImage(named: "xmarkRed")
            //Выполнено
        case 3 : statusImage.image = UIImage(named: "doneTask")
            //Создано, Выполняется специалистом, Переназначено
        default : statusImage.image = UIImage(named: "grayElliipse")
        }
        tittleLabel.text = task.title
    }
    
    func configureReport(task: TourTaskReports) {
        switch task.status ?? 0 {
            //Отклонено
        case 1 : statusImage.image = UIImage(named: "xmarkRed")
            //Выполнено
        case 3 : statusImage.image = UIImage(named: "doneTask")
            //Создано, Выполняется специалистом, Переназначено
        default : statusImage.image = UIImage(named: "grayElliipse")
        }
        tittleLabel.text = task.task.title
    }
}
