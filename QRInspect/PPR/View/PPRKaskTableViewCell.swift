//
//  PPRKaskTableViewCell.swift
//  QRInspect
//
//  Created by Денис Чупров on 19.05.2023.
//

import Foundation
import UIKit

final class PPRTaskTableViewCell: UITableViewCell {
    static let reuseID = "PPRTaskTableViewCell"
    
    @IBOutlet private weak var tittleLabel: UILabel!
    @IBOutlet private weak var statusImage: UIImageView!
    @IBOutlet weak var qrButton: UIButton!
    
    
    func configure(ppr: MaintenanceTask) {
        tittleLabel.text = ppr.title
        switch ppr.status {
            //Отклонено
        case 1 : statusImage.image = UIImage(named: "xmarkRed")
            //Выполнено
        case 3 : statusImage.image = UIImage(named: "doneTask")
            //Создано, Выподняется специалистом, Переназначено
        default : statusImage.image = UIImage(named: "grayElliipse")
        }
    }
    
    func configure(pprWithReports: WorkTaskReports?) {
        tittleLabel.text = pprWithReports?.task?.title
        switch pprWithReports?.status {
            //Отклонено
        case 1 : statusImage.image = UIImage(named: "xmarkRed")
            //Выполнено
        case 3 : statusImage.image = UIImage(named: "doneTask")
            //Создано, Выподняется специалистом, Переназначено
        default : statusImage.image = UIImage(named: "grayElliipse")
        }
    }
    
    
}
