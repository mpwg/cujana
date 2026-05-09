import Foundation

nonisolated public enum OpenMeteoWeatherMapper {
    public static func map(_ dto: OpenMeteoWeatherResponseDTO, generatedAt: Date) throws -> [WeatherForecast] {
        let coordinate = try LocationCoordinate(latitude: dto.latitude, longitude: dto.longitude)
        let dailyConditions = try dto.daily.time.indices.map { index in
            guard
                dto.daily.weatherCode.indices.contains(index),
                dto.daily.temperature2mMax.indices.contains(index)
            else {
                throw WeatherDataError.decodingFailed
            }

            return WeatherForecast.DailyCondition(
                date: try date(from: dto.daily.time[index]),
                temperature: dto.daily.temperature2mMax[index],
                conditionCode: dto.daily.weatherCode[index]
            )
        }

        guard dailyConditions.isEmpty == false else {
            return []
        }

        return [
            WeatherForecast(
                coordinate: coordinate,
                generatedAt: generatedAt,
                dailyConditions: dailyConditions
            )
        ]
    }

    private static func date(from string: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: string) else {
            throw WeatherDataError.decodingFailed
        }

        return date
    }
}
