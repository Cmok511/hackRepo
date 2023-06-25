//
//  TasksFromPlotTableViewCell.swift
//  hackathon
//
//  Created by iOS AXAS on 24.06.2023.
//

import UIKit

final class TasksFromPlotTableViewCell: UITableViewCell {

    @IBOutlet weak private var tasksForGrapedinoCollectionView: UICollectionView!

    //MARK: lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    //MARK: setupUI
    private func setupUI() {
        tasksForGrapedinoCollectionView.dataSource = self
    }

}

//MARK: - UICollectionViewDataSource
extension TasksFromPlotTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskForPlots", for: indexPath) as! TasksForGrapedinoCollectionViewCell

        return cell
    }


}
