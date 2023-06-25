//
//  LocationsTableViewCell.swift
//  QRInspect
//
//

import UIKit

class LocationsTableViewCell: UITableViewCell {
    static let ruuseID = "LocationsTableViewCell"
    @IBOutlet private weak var locationcollectionView: UICollectionView!
    
    private var locationsArray: [GettingLocation] = [] {
        didSet {
            locationcollectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        locationcollectionView.dataSource = self
    }
    func configure(_ array: [GettingLocation]) {
        locationsArray = array
    }
}
//MARK: - UICollectionViewDataSource
extension LocationsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationsArray.count
     
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationColectionViewCell.reuseID, for: indexPath) as! LocationColectionViewCell
            cell.configure(locationsArray[indexPath.item])
        return cell
          
    }
}
