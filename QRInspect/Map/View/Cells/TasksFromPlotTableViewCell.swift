//
//  TasksFromPlotTableViewCell.swift
//  hackathon
//
//  Created by iOS AXAS on 24.06.2023.
//

import UIKit
import PromiseKit

final class TasksFromPlotTableViewCell: UITableViewCell {


    @IBOutlet weak private var tasksForGrapedinoCollectionView: UICollectionView!

    private var tasks: [WorkTask?]?

    //MARK: lifecycle
    override func awakeFromNib() {
        getTasks()
        super.awakeFromNib()

        setupUI()
    }

    //MARK: setupUI
    private func setupUI() {
        tasksForGrapedinoCollectionView.dataSource = self

    }

    //MARK: get tasks
    private func getTasks() {
        firstly(execute: {
            TaskModel.fetchTaskList(isActive: true, page: 1)
        }).done({ data in
            self.tasks = data.data
            self.tasksForGrapedinoCollectionView.reloadData()
        }).catch { error in
            dump(error)
        }
    }

}

//MARK: - UICollectionViewDataSource
extension TasksFromPlotTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tasks?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskForPlots", for: indexPath) as! TasksForGrapedinoCollectionViewCell
        cell.configure(task: (tasks?[indexPath.item])!)
        return cell
    }


}
