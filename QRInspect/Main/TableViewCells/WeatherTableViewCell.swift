//
//  WeatherTableViewCell.swift
//  QRInspect
//
//

import UIKit

final class WeatherTableViewCell: UITableViewCell {

    //temperature
    @IBOutlet weak private var dateOfWather: UILabel!
    @IBOutlet weak private var temperatureofWether: UILabel!
    @IBOutlet weak private var humidity: UILabel!
    @IBOutlet weak private var filsLikeLabel: UILabel!
    
    static let reuseID = "WeatherTableViewCell"

    //MARK: awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    //MARK: configure cell
    func configure(temp: Int, humidity: Int, dateOfWather: Int, predicate: String) {
        temperatureofWether.text = "\(temp) C"
        self.humidity.text = "\(humidity) %"
        self.dateOfWather.text = "\(dateOfWather.toDay)"
        filsLikeLabel.text = predicate
    }

}
