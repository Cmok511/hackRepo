//
//  ReconendationsTableViewCell.swift
//  QRInspect
//
//  Created by Денис Чупров on 24.06.2023.
//

import UIKit

final class ReconendationsTableViewCell: UITableViewCell {
    static let reuseID = "ReconendationsTableViewCell"
    @IBOutlet private weak var reconendationCollectionView: UICollectionView!
    private var recomendationArray: [GettingRecomendation] = [] {
        didSet {
            reconendationCollectionView.reloadData()
        }
    }

    //MARK: awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
        reconendationCollectionView.dataSource = self
    }

    //MARK: configure cell
    func configure(_ array: [GettingRecomendation]) {
        recomendationArray = array
    }

}
//MARK: - UICollectionViewDataSource
extension ReconendationsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return recomendationArray.count
  
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReconendationCollectionViewCell.reuseID, for: indexPath) as! ReconendationCollectionViewCell
        cell.configure(recomendationArray[indexPath.item])
        return cell
    }
}
