//
//  DescriptionTableViewCell.swift
//  hackathon
//
//  Created by iOS AXAS on 24.06.2023.
//

import UIKit

protocol DescriptionTableViewCellDelegate: AnyObject {
    func sendChangeRowHeight()
}

final class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak private var changeHeightButton: UIButton!

    private var expandedHeight: Bool = false

    var delegate: DescriptionTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBAction private func expandButton(_ sender: UIButton) {
        self.delegate?.sendChangeRowHeight()
        expandedHeight.toggle()

        if expandedHeight {
            changeHeightButton.titleLabel?.text = "свернуть"
        } else {
            changeHeightButton.titleLabel?.text = "развернуть"
        }
    }


}
