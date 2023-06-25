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
    
    @IBOutlet weak private var date: UILabel!
    @IBOutlet weak private var deadline: UIButton!
    @IBOutlet weak private var number: UILabel!
    @IBOutlet weak private var address: UILabel!
    @IBOutlet weak private var taskDesc: UILabel!
    @IBOutlet weak private var isUrgentImage: UIImageView!
    @IBOutlet weak private var isReturnedImage: UIImageView!
    
    //MARK: awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK: configure cell
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
            deadline.setTitle("Завершена", for: .normal)
        } else { //isActive
            deadline.setTitleColor(.white, for: .normal)
            let text = task?.deadline?.toDay
            deadline.setTitle(text, for: .normal)
            switch task?.status {
            case 0 : //created
                deadline.backgroundColor = UIColor(named: "AccentColor")
                deadline.setTitleColor(.white, for: .normal)
            case 1: //rejected
                deadline.setTitleColor(.white, for: .normal)
                deadline.tintColor = UIColor(named: "AccentColor")
            case 2: //inProgress
                deadline.backgroundColor = .systemGreen
                deadline.setTitleColor(.white, for: .normal)
            case 3: //complited
                deadline.backgroundColor = .clear
                deadline.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
            case 4 : //reassigned
                deadline.backgroundColor = .systemRed
                deadline.setTitleColor(.white, for: .normal)
            default : break
            }
        }
    }
    
}
