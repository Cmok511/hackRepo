//
//  TasksTableViewCell.swift
//  QRInspect
//
//  Created by Денис Чупров on 24.06.2023.
//

import UIKit

class TasksTableViewCell: UITableViewCell {
    static let reuseID = "TasksTableViewCell"
    
    @IBOutlet private weak var tasksCollectionView: UICollectionView!
 
    private var urgentTasks: [WorkTask?] = [] {
        didSet {
            tasksCollectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        tasksCollectionView.dataSource = self
    }
    
    func configure(_ array: [WorkTask?]) {
        urgentTasks = array
    }

}
//MARK: - UICollectionViewDataSource
extension TasksTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urgentTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCollectionViewCell.reuseID, for: indexPath) as! TaskCollectionViewCell
            cell.configure(task: urgentTasks[indexPath.item], isActive: true)
            return cell
    }
}
