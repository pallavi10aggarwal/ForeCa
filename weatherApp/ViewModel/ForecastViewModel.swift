import UIKit
import PromiseKit
import JGProgressHUD
import MapKit

class ForecastViewModel: NSObject {

	var location: String
	var daysForecast: [DayViewModel]
	var hud: JGProgressHUD!

	override init() {
		location = ""
		daysForecast = []
		super.init()

		showLoadingIndicator()
		self.getCurrentLocation().done{ coord -> Void in
			self.fetchWeatherForecastDetails(
				latitude: coord.latitude,
				longitude: coord.longitude
			).done { model -> Void in
				self.daysForecast = model
			}.ensure {
				NotificationCenter.default.post(
					name: NSNotification.Name(rawValue: "updateForecastData"),
					object: nil,
					userInfo: nil
				)
			}
		}.ensure {
			self.dismissLoadingIndicator()
		}.catch { (error) in
			print(error.localizedDescription)
		}
	}

}

extension ForecastViewModel {

	func showLoadingIndicator() {
		hud = JGProgressHUD(style: .dark)
		hud.textLabel.text = "Loading"
        guard let view = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
			return
		}
		hud.show(in: view)
	}

	func dismissLoadingIndicator() {
		hud.dismiss(afterDelay: 2.0)
	}

}

extension ForecastViewModel {

	func getCurrentLocation() -> Promise<CLLocationCoordinate2D>  {
		
        return Promise<CLLocationCoordinate2D> { seal in
            CLLocationManager.requestLocation().done { locations in
                return seal.fulfill(locations[0].coordinate)
			}.catch { (error) in
                seal.reject(error)
			}
		}
        
}

	func fetchWeatherForecastDetails(latitude: Double, longitude: Double) -> Promise<[DayViewModel]> {
        return Promise { seal in
			let urlString = "\(Config.BaseURL)?lat=\(latitude)&lon=\(longitude)" +
			"&appid=\(Config.APIKey)"

			var request: URLRequest?
			if let url = URL(string: urlString) {
				request = URLRequest(url: url)
			}

			let session = URLSession.shared
			//Force upwrapping request since it's never be nil
			let dataTask = session.dataTask(with: request!) { data, response, error in
				if let data = data,
				   let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Dictionary<String, Any>,
				   let result = self.parseForecastData(jsonDictionary: json) {
                    seal.fulfill(result)
				} else if let error = error {
                    seal.reject(error)
				} else {
					let error = NSError(domain: "WeatherTron", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                    seal.reject(error)
				}
			}
			dataTask.resume()
		}
	}

}

extension ForecastViewModel {

	func parseForecastData(jsonDictionary: Dictionary<String, Any>) ->  [DayViewModelMapper]?{

		if let list = jsonDictionary["list"] as? [[String: Any]] {

			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .long
			dateFormatter.timeStyle = .none

			var dayModels: [DayModel] = []
			var l_dayModel = DayModel(forecastDate: "", forecastTime: "", weatherList:[])
			var dayDate:String = ""

			for i in (0..<list.count) {
				if let main = list[i]["main"] as? Dictionary<String, AnyObject>,
				   let temp = main["temp"] as? Double,
				   let weatherArray = list[i]["weather"] as? [[String: Any]],
				   let weatherCondition = weatherArray[0]["main"] as? String,
				   let countryObj = jsonDictionary["city"] as? Dictionary<String, AnyObject>,
				   let cityName = countryObj["name"] as? String,
				   let time = list[i]["dt_txt"] as? String {

					self.location = cityName
					let timeComponents = time.components(separatedBy: " ")

					if dayDate == "" || dayDate == timeComponents[0] {
						dayDate = timeComponents[0]
						if l_dayModel.forecastDate == "",
						   l_dayModel.forecastTime == "" {
							l_dayModel.forecastDate = timeComponents[0]
							l_dayModel.forecastTime = timeComponents[1]
						}

						let weatherModel = WeatherModel.init(temperature: temp, weatherCondition: weatherCondition)
						l_dayModel.weatherList.append(weatherModel)
					} else {
						//Append to DayModel Array
						dayModels.append(l_dayModel)

						//Instantiate new object
						l_dayModel = DayModel(forecastDate: "", forecastTime: "", weatherList:[])

						l_dayModel.forecastDate = timeComponents[0]
						l_dayModel.forecastTime = timeComponents[1]

						let weatherModel = WeatherModel.init(temperature: temp, weatherCondition: weatherCondition)
						l_dayModel.weatherList.append(weatherModel)

						//re-assign the value for new day
						dayDate = l_dayModel.forecastDate
					}
				}
			}

			//Create the view model list
			var dayViewModelList:[DayViewModelMapper] = []

			for tempDayModel in dayModels {
				dayViewModelList.append(DayViewModelMapper(dayModel: tempDayModel))
			}
			return dayViewModelList
		}
		return [DayViewModelMapper]()
	}

}
