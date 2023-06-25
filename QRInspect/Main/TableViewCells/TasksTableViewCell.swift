//
//  TasksTableViewCell.swift
//  QRInspect
//
//  Created by Денис Чупров on 24.06.2023.
//

import UIKit

protocol TasksTableViewCellDelegate: AnyObject {
    func selectTask(value: Int)
}

class TasksTableViewCell: UITableViewCell {
    static let reuseID = "TasksTableViewCell"
    
    private let notTasksLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "У вас нет строчных задач"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    @IBOutlet private weak var tasksCollectionView: UICollectionView!
    weak var delegete: TasksTableViewCellDelegate?
    private var urgentTasks: [WorkTask?] = [] {
        didSet {
            tasksCollectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        tasksCollectionView.dataSource = self
        tasksCollectionView.delegate = self
        addSubview(notTasksLabel)
        NSLayoutConstraint.activate([
            notTasksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            notTasksLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            notTasksLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            notTasksLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(_ array: [WorkTask?]) {
        urgentTasks = array
        notTasksLabel.isHidden = !urgentTasks.isEmpty
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
//MARK: - UICollectionViewDelegate
extension TasksTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegete?.selectTask(value: indexPath.item)
    }
    
}
