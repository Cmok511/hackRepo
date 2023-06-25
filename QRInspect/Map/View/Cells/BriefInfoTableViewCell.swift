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

    var data: GetLocationsResponseData?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        dump(data)
    }

    private func setupUI() {
        FIOLabel.text = "\(data?.user?.lastName ?? "Совиньонов") \(data?.user?.firstName ?? "Брют") \(data?.user?.patronymic ?? "Кишмишевич")"
        professionLabel.text = data?.user?.group?.name ?? "Агроном"
        temperatureLabel.text = String(data?.temperature ?? 35) + "  °C"
        humidityLabel.text = String(data?.humidity ?? 56) + "  %"
        stageLabel.text = Stage.allCases[data?.stage ?? 0].rawValue
        sortLabel.text = data?.sort ?? "Совиньон Блан"
        squareLabel.text = String((Int(data?.lon ?? 44) - 5)*(Int(data?.lon ?? 44) - 5)) + "  m"
    }

}
