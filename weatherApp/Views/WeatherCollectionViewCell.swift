import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var viewModel: WeatherViewModel? {
        didSet {
           self.weatherConditionLabel.text = viewModel?.weatherCondition
           self.temperatureLabel.text = viewModel?.temperature
        }
    }
}
