import Foundation
import Testing
@testable import Cujana

struct OpenMeteoWeatherTests {

    @Test func dtoDecodesOpenMeteoDailyWeatherPayload() throws {
        let json = """
        {
          "latitude": 48.2,
          "longitude": 16.37,
          "daily": {
            "time": ["2026-05-08"],
            "weather_code": [2],
            "temperature_2m_max": [18.4]
          }
        }
        """

        let dto = try JSONDecoder().decode(OpenMeteoWeatherResponseDTO.self, from: Data(json.utf8))

        #expect(dto.latitude == 48.2)
        #expect(dto.longitude == 16.37)
        #expect(dto.daily.time == ["2026-05-08"])
        #expect(dto.daily.weatherCode == [2])
        #expect(dto.daily.temperature2mMax == [18.4])
    }

    @Test func mapperCreatesWeatherForecastFromDailyValues() throws {
        let generatedAt = Date(timeIntervalSince1970: 500)
        let dto = OpenMeteoWeatherResponseDTO(
            latitude: 48.2082,
            longitude: 16.3738,
            daily: OpenMeteoWeatherDailyDTO(
                time: ["2026-05-08", "2026-05-09"],
                weatherCode: [2, 61],
                temperature2mMax: [18.4, 21.2]
            )
        )

        let forecasts = try OpenMeteoWeatherMapper.map(dto, generatedAt: generatedAt)

        #expect(forecasts.count == 1)
        #expect(forecasts[0].coordinate == (try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)))
        #expect(forecasts[0].generatedAt == generatedAt)
        #expect(forecasts[0].dailyConditions == [
            WeatherForecast.DailyCondition(
                date: try #require(date("2026-05-08")),
                temperature: 18.4,
                conditionCode: 2
            ),
            WeatherForecast.DailyCondition(
                date: try #require(date("2026-05-09")),
                temperature: 21.2,
                conditionCode: 61
            )
        ])
    }

    @Test func repositoryLoadsForecastsThroughInjectedAPIClient() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = Date(timeIntervalSince1970: 500)
        let apiClient = FakeOpenMeteoWeatherAPIClient(
            response: OpenMeteoWeatherResponseDTO(
                latitude: 48.2082,
                longitude: 16.3738,
                daily: OpenMeteoWeatherDailyDTO(
                    time: ["2026-05-08"],
                    weatherCode: [3],
                    temperature2mMax: [20.1]
                )
            )
        )
        let repository = OpenMeteoWeatherRepository(apiClient: apiClient, now: { generatedAt })

        let forecasts = try await repository.weatherForecast(
            for: coordinate,
            from: try #require(date("2026-05-08")),
            to: try #require(date("2026-05-08"))
        )

        #expect(forecasts.first?.dailyConditions.first?.temperature == 20.1)
        #expect(forecasts.first?.dailyConditions.first?.conditionCode == 3)
    }

    private func date(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}

private struct FakeOpenMeteoWeatherAPIClient: OpenMeteoWeatherAPIClient {
    let response: OpenMeteoWeatherResponseDTO

    func weatherResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> OpenMeteoWeatherResponseDTO {
        response
    }
}
