import Foundation
import Testing
@testable import Cujana

struct OpenMeteoPollenTests {

    @Test func mapperCreatesDomainForecastFromDailyPollenValues() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = Date(timeIntervalSince1970: 500)
        let firstDate = Date(timeIntervalSince1970: 0)
        let secondDate = Date(timeIntervalSince1970: 86_400)
        let dto = OpenMeteoPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: generatedAt,
            daily: OpenMeteoPollenResponseDTO.Daily(
                dates: [firstDate, secondDate],
                variables: [
                    OpenMeteoPollenResponseDTO.DailyVariable(
                        pollenType: .birch,
                        values: [0, 51]
                    ),
                    OpenMeteoPollenResponseDTO.DailyVariable(
                        pollenType: .grass,
                        values: [201, 9]
                    )
                ]
            )
        )

        let forecasts = try OpenMeteoPollenMapper.map(dto)

        #expect(forecasts.count == 1)
        #expect(forecasts[0].coordinate == coordinate)
        #expect(forecasts[0].generatedAt == generatedAt)
        #expect(forecasts[0].validFrom == firstDate)
        #expect(forecasts[0].validUntil == secondDate)
        #expect(forecasts[0].dailyLevels == [
            PollenForecast.DailyLevel(date: firstDate, pollenType: .birch, level: .none),
            PollenForecast.DailyLevel(date: secondDate, pollenType: .birch, level: .high),
            PollenForecast.DailyLevel(date: firstDate, pollenType: .grass, level: .extreme),
            PollenForecast.DailyLevel(date: secondDate, pollenType: .grass, level: .low)
        ])
    }

    @Test func repositoryLoadsForecastsThroughInjectedAPIClient() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let date = Date(timeIntervalSince1970: 0)
        let apiClient = FakeOpenMeteoPollenAPIClient(
            response: OpenMeteoPollenResponseDTO(
                coordinate: coordinate,
                generatedAt: date,
                daily: OpenMeteoPollenResponseDTO.Daily(
                    dates: [date],
                    variables: [
                        OpenMeteoPollenResponseDTO.DailyVariable(
                            pollenType: .ragweed,
                            values: [12]
                        )
                    ]
                )
            )
        )
        let repository = OpenMeteoPollenRepository(apiClient: apiClient)

        let forecasts = try await repository.pollenForecast(
            for: coordinate,
            from: date,
            to: date
        )

        #expect(forecasts.first?.dailyLevels == [
            PollenForecast.DailyLevel(date: date, pollenType: .ragweed, level: .moderate)
        ])
    }
}

private struct FakeOpenMeteoPollenAPIClient: OpenMeteoPollenAPIClient {
    let response: OpenMeteoPollenResponseDTO

    func pollenResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> OpenMeteoPollenResponseDTO {
        response
    }
}
