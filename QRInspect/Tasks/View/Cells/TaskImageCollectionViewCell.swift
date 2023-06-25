//
//  TaskImageCollectionViewCell.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import UIKit

final class TaskImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!

    //MARK: awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
        image.addRadius()
    }
}
