//
//  BriefInfoTableViewCell.swift
//  hackathon
//
//  Created by iOS AXAS on 24.06.2023.
//

import UIKit

final class BriefInfoTableViewCell: UITableViewCell {

    @IBOutlet weak private var professionLabel: UILabel!
    @IBOutlet weak private var FIOLabel: UILabel!

    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var humidityLabel: UILabel!
    @IBOutlet weak private var stageLabel: UILabel!
    @IBOutlet weak private var sortLabel: UILabel!
    @IBOutlet weak private var squareLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
