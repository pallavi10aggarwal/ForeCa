import UIKit

protocol WeatherViewModel {
	var temperature: String { get }
	var weatherCondition: String { get }
}

class WeatherViewModelMapper: NSObject, WeatherViewModel {

	var temperature: String
	var weatherCondition: String

	init(weather: WeatherModel) {
		temperature =  String(format: "%.0f °C", weather.temperature - 273.15)
		weatherCondition = weather.weatherCondition
		super.init()
	}

}
