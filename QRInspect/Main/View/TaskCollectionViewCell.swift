//
//  TaskCollectionViewCell.swift
//  QRInspect
//
//  Created by Денис Чупров on 24.06.2023.
//

import Foundation
import UIKit

final class TaskCollectionViewCell: UICollectionViewCell {
    static let reuseID = "TaskCollectionViewCell"
    
    @IBOutlet weak private var backView: UIView!
    @IBOutlet weak private var date: UILabel!
    @IBOutlet weak private var deadline: UILabel!
    @IBOutlet weak private var number: UILabel!
    @IBOutlet weak private var address: UILabel!
    @IBOutlet weak private var taskDesc: UILabel!
    @IBOutlet weak private var isUrgentImage: UIImageView!
    @IBOutlet weak private var isReturnedImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.addRadius()
    }
    
    ///configure cell
    func configure(task: WorkTask?, isActive: Bool) {
        date.text = task?.created?.toDay
        number.text = "№\(task?.id ?? 0)"
        taskDesc.text = task?.title
        address.text = task?.location?.address?.name
        isUrgentImage.isHidden = !(task?.isUrgent ?? false)
        isReturnedImage.isHidden = !((task?.returnedCount ?? 0) > 1 )
        //finished
        if !isActive {
            deadline.backgroundColor = .white
            deadline.text = "Завершена"
            deadline.textColor = UIColor(named: "AccentColor")
        } else { //isActive
            deadline.textColor = .white
            deadline.text = task?.deadline?.toDay
            switch task?.status {
            case 0 : //created
                deadline.backgroundColor = UIColor(named: "AccentColor")
                deadline.textColor = .white
            case 1: //rejected
                deadline.backgroundColor = .white
                deadline.textColor = .black
            case 2: //inProgress
                deadline.backgroundColor = .systemGreen
                deadline.textColor = .white
            case 3: //complited
                deadline.backgroundColor = .clear
                deadline.textColor = UIColor(named: "AccentColor")
            case 4 : //reassigned
                deadline.backgroundColor = .systemRed
                deadline.textColor = .white
            default : break
            }
        }
    }
    
}
