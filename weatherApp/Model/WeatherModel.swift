import UIKit

class WeatherModel: NSObject {

	var temperature: Double
	var weatherCondition: String

	init(temperature: Double, weatherCondition: String) {
		self.temperature = temperature
		self.weatherCondition = weatherCondition
	}

}
