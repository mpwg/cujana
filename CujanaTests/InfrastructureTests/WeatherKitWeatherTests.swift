import Foundation
import Testing
@testable import Cujana

struct WeatherKitWeatherTests {

    @Test func dtoDecodesWeatherKitDailyPayload() throws {
        let json = """
        {
          "coordinate": {
            "latitude": 48.2082,
            "longitude": 16.3738
          },
          "days": [
            {
              "date": "2026-05-08T00:00:00Z",
              "condition": "partlyCloudy",
              "highTemperatureCelsius": 18.4
            }
          ]
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dto = try decoder.decode(WeatherKitWeatherResponseDTO.self, from: Data(json.utf8))

        #expect(dto.coordinate == (try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)))
        #expect(dto.days == [
            WeatherKitWeatherDayDTO(
                date: try #require(isoDate("2026-05-08T00:00:00Z")),
                condition: "partlyCloudy",
                highTemperatureCelsius: 18.4
            )
        ])
    }

    @Test func mapperCreatesWeatherForecastFromDailyValues() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = Date(timeIntervalSince1970: 500)
        let firstDate = try #require(isoDate("2026-05-08T00:00:00Z"))
        let secondDate = try #require(isoDate("2026-05-09T00:00:00Z"))
        let dto = WeatherKitWeatherResponseDTO(
            coordinate: coordinate,
            days: [
                WeatherKitWeatherDayDTO(
                    date: firstDate,
                    condition: "partlyCloudy",
                    highTemperatureCelsius: 18.4
                ),
                WeatherKitWeatherDayDTO(
                    date: secondDate,
                    condition: "rain",
                    highTemperatureCelsius: 21.2
                )
            ]
        )

        let forecasts = try WeatherKitWeatherMapper.map(dto, generatedAt: generatedAt)

        #expect(forecasts.count == 1)
        #expect(forecasts[0].coordinate == coordinate)
        #expect(forecasts[0].generatedAt == generatedAt)
        #expect(forecasts[0].dailyConditions == [
            WeatherForecast.DailyCondition(date: firstDate, temperature: 18.4, conditionCode: 2),
            WeatherForecast.DailyCondition(date: secondDate, temperature: 21.2, conditionCode: 61)
        ])
    }

    @Test func mapperMapsWeatherKitConditionsToDashboardCodes() {
        #expect(WeatherKitWeatherMapper.conditionCode(for: "clear") == 0)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "mostlyClear") == 1)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "partlyCloudy") == 2)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "cloudy") == 3)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "foggy") == 45)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "drizzle") == 51)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "rain") == 61)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "snow") == 71)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "hail") == 77)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "thunderstorms") == 95)
        #expect(WeatherKitWeatherMapper.conditionCode(for: "blizzard") == 99)
    }

    @Test func repositoryLoadsForecastsThroughInjectedAPIClient() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = Date(timeIntervalSince1970: 500)
        let date = try #require(isoDate("2026-05-08T00:00:00Z"))
        let apiClient = FakeWeatherKitWeatherAPIClient(
            response: WeatherKitWeatherResponseDTO(
                coordinate: coordinate,
                days: [
                    WeatherKitWeatherDayDTO(
                        date: date,
                        condition: "cloudy",
                        highTemperatureCelsius: 20.1
                    )
                ]
            )
        )
        let repository = WeatherKitWeatherRepository(apiClient: apiClient, now: { generatedAt })

        let forecasts = try await repository.weatherForecast(
            for: coordinate,
            from: date,
            to: date
        )

        #expect(forecasts.first?.dailyConditions.first?.temperature == 20.1)
        #expect(forecasts.first?.dailyConditions.first?.conditionCode == 3)
    }

    @Test func serviceClientNormalizesForecastRangeToFutureDaysWithBuffer() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let now = try #require(isoDate("2026-05-10T13:00:00Z"))
        let startDate = try #require(isoDate("2026-05-03T13:00:00Z"))
        let endDate = try #require(isoDate("2026-05-13T13:00:00Z"))

        let range = WeatherKitWeatherServiceClient.forecastDateRange(
            from: startDate,
            to: endDate,
            now: now,
            calendar: calendar
        )

        #expect(range.startDate == (try #require(isoDate("2026-05-10T00:00:00Z"))))
        #expect(range.endDate == (try #require(isoDate("2026-05-14T00:00:00Z"))))
    }

    private func isoDate(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }
}

private struct FakeWeatherKitWeatherAPIClient: WeatherKitWeatherAPIClient {
    let response: WeatherKitWeatherResponseDTO

    func weatherResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> WeatherKitWeatherResponseDTO {
        response
    }
}
