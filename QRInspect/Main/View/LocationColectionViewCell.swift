//
//  LocationColectionViewCell.swift
//  QRInspect
//
//

import Foundation
import UIKit
import SDWebImage

final class LocationColectionViewCell: UICollectionViewCell {
    static let reuseID = "LocationColectionViewCell"
    
    @IBOutlet private weak var coverImage: UIImageView!
    @IBOutlet private weak var titleLabel:UILabel!
    @IBOutlet private var temperatyreLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!

    //MARK: awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //MARK: configure cell
    func configure(_ location: GettingLocation) {
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = location.name
        temperatyreLabel.text = "\(location.temperature ?? 0) °C"
        humidityLabel.text = "\(location.temperature ?? 0) %"
        stateLabel.text = Stage.allCases[location.state ?? 0].rawValue
        if location.cover == nil {
            coverImage.image = UIImage(named: "locationImage")
        }
        guard let urlStr = location.cover else { return }
        guard let url = URL(string: urlStr) else { return }
        coverImage.sd_setImage(with: url)
    }
}
