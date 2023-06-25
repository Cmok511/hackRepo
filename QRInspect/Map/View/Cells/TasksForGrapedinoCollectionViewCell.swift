//
//  TasksForGrapedinoCollectionViewCell.swift
//  hackathon
//
//  Created by iOS AXAS on 24.06.2023.
//

import UIKit

final class TasksForGrapedinoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var datetimeLabel: UILabel!
    @IBOutlet weak private var taskNumberLabel: UILabel!
    @IBOutlet weak private var locationLabel: UILabel!
    @IBOutlet weak private var taskDescriptionLabel: UILabel!
    @IBOutlet weak private var deadlineLabel: UILabel!

    //MARK: configure cell
    func configure(task: WorkTask) {
        datetimeLabel.text = task.created?.toDay
        taskNumberLabel.text = "№\(String(task.id!))"
        locationLabel.text = task.location?.name
        taskDescriptionLabel.text = task.description
        deadlineLabel.text = "до \(task.deadline?.toDay ?? "24.06.2023")"
    }
}
