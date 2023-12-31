//
//  WorningCollectionViewCell.swift
//  QRInspect
//
//

import Foundation
import UIKit

final class ReconendationCollectionViewCell: UICollectionViewCell {
    static let reuseID = "ReconendationCollectionViewCell"
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLAbel: UILabel!
    @IBOutlet private weak var reconendationLAbel: UILabel!
    @IBOutlet private weak var textLAbel: UILabel!

    //MARK: awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //MARK: configure cell
    func configure(_ recomendation: GettingRecomendation) {
        dateLabel.text = recomendation.created?.toDay
        titleLAbel.text = recomendation.locationName
        reconendationLAbel.text = recomendation.title
        textLAbel.text = recomendation.description
        addRadius()
    }
    
}
