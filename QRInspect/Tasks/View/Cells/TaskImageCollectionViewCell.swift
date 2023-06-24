//
//  TaskImageCollectionViewCell.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 11.03.2023.
//

import UIKit

class TaskImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.addRadius()
    }
}
