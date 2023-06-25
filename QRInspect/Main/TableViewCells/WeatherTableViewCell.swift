//
//  WeatherTableViewCell.swift
//  QRInspect
//
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    //temperature
    @IBOutlet weak var dateOfWather: UILabel!
    @IBOutlet weak var temperatureofWether: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var filsLikeLabel: UILabel!
    
    static let reuseID = "WeatherTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    func configure(temp: Int, humidity: Int, dateOfWather: Int, predicate: String) {
        temperatureofWether.text = "\(temp) C"
        self.humidity.text = "\(humidity) %"
        self.dateOfWather.text = "\(dateOfWather.toDay)"
        filsLikeLabel.text = predicate
    }

}
