import Foundation

nonisolated public enum WeatherKitWeatherMapper {
    public static func map(_ dto: WeatherKitWeatherResponseDTO, generatedAt: Date) throws -> [WeatherForecast] {
        let dailyConditions = dto.days.map { day in
            WeatherForecast.DailyCondition(
                date: day.date,
                temperature: day.highTemperatureCelsius,
                conditionCode: conditionCode(for: day.condition)
            )
        }

        guard dailyConditions.isEmpty == false else {
            return []
        }

        return [
            WeatherForecast(
                coordinate: dto.coordinate,
                generatedAt: generatedAt,
                dailyConditions: dailyConditions
            )
        ]
    }

    static func conditionCode(for condition: String) -> Int {
        conditionCodes[condition, default: 2]
    }

    private static let conditionCodes = [
        "clear": 0,
        "hot": 0,
        "mostlyClear": 1,
        "frigid": 1,
        "partlyCloudy": 2,
        "breezy": 2,
        "windy": 2,
        "cloudy": 3,
        "mostlyCloudy": 3,
        "foggy": 45,
        "haze": 45,
        "smoky": 45,
        "blowingDust": 45,
        "drizzle": 51,
        "freezingDrizzle": 51,
        "sunShowers": 51,
        "rain": 61,
        "freezingRain": 61,
        "heavyRain": 61,
        "flurries": 71,
        "snow": 71,
        "heavySnow": 71,
        "blowingSnow": 71,
        "sunFlurries": 71,
        "sleet": 77,
        "hail": 77,
        "wintryMix": 77,
        "isolatedThunderstorms": 95,
        "scatteredThunderstorms": 95,
        "thunderstorms": 95,
        "strongStorms": 99,
        "tropicalStorm": 99,
        "hurricane": 99,
        "blizzard": 99
    ]
}
