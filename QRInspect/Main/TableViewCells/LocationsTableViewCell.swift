//
//  LocationsTableViewCell.swift
//  QRInspect
//
//

import UIKit

protocol LocationsTableViewCellDelegate: AnyObject {
    func selectLocation(_ value: Int)
}

final class LocationsTableViewCell: UITableViewCell {
    static let ruuseID = "LocationsTableViewCell"
    @IBOutlet private weak var locationcollectionView: UICollectionView!
    weak var delegate: LocationsTableViewCellDelegate?
    
    private var locationsArray: [GettingLocation] = [] {
        didSet {
            locationcollectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        locationcollectionView.dataSource = self
        locationcollectionView.delegate = self
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
extension LocationsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectLocation(indexPath.item)
    }
}
