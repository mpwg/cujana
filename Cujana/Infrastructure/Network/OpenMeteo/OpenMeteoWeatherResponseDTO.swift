import Foundation

nonisolated public struct OpenMeteoWeatherResponseDTO: Codable, Equatable, Sendable {
    public struct Daily: Codable, Equatable, Sendable {
        public let time: [String]
        public let weatherCode: [Int]
        public let temperature2mMax: [Double]

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
        }

        public init(time: [String], weatherCode: [Int], temperature2mMax: [Double]) {
            self.time = time
            self.weatherCode = weatherCode
            self.temperature2mMax = temperature2mMax
        }
    }

    public let latitude: Double
    public let longitude: Double
    public let daily: Daily

    public init(latitude: Double, longitude: Double, daily: Daily) {
        self.latitude = latitude
        self.longitude = longitude
        self.daily = daily
    }
}
