import Foundation
import Testing
@testable import Cujana

struct OpenMeteoPollenTests {

    @Test func dtoDecodesFromJSONPayload() throws {
        let json = """
        {
          "coordinate": {
            "latitude": 48.2082,
            "longitude": 16.3738
          },
          "generatedAt": "2026-05-07T08:00:00Z",
          "daily": {
            "dates": [
              "2026-05-07T00:00:00Z"
            ],
            "variables": [
              {
                "pollenType": 3,
                "values": [
                  12.5
                ]
              }
            ]
          }
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dto = try decoder.decode(OpenMeteoPollenResponseDTO.self, from: Data(json.utf8))

        #expect(dto.coordinate == (try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)))
        #expect(dto.daily.dates == [try #require(isoDate("2026-05-07T00:00:00Z"))])
        #expect(dto.daily.variables == [
            OpenMeteoPollenResponseDTO.DailyVariable(pollenType: .birch, values: [12.5])
        ])
    }

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

    @Test func mapperReturnsNoForecastWhenDailyDatesAreEmpty() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let dto = OpenMeteoPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: Date(timeIntervalSince1970: 0),
            daily: OpenMeteoPollenResponseDTO.Daily(
                dates: [],
                variables: [
                    OpenMeteoPollenResponseDTO.DailyVariable(
                        pollenType: .birch,
                        values: [42]
                    )
                ]
            )
        )

        let forecasts = try OpenMeteoPollenMapper.map(dto)

        #expect(forecasts.isEmpty)
    }

    @Test func mapperIgnoresPollenValuesWithoutMatchingDate() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let date = Date(timeIntervalSince1970: 0)
        let dto = OpenMeteoPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: date,
            daily: OpenMeteoPollenResponseDTO.Daily(
                dates: [date],
                variables: [
                    OpenMeteoPollenResponseDTO.DailyVariable(
                        pollenType: .grass,
                        values: [12, 75]
                    )
                ]
            )
        )

        let forecasts = try OpenMeteoPollenMapper.map(dto)

        #expect(forecasts.first?.dailyLevels == [
            PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .moderate)
        ])
    }

    @Test func sdkClientAggregatesHourlyPollenValuesToDailyMaximums() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = Date(timeIntervalSince1970: 500)
        let firstDay = Date(timeIntervalSince1970: 0)
        let secondDay = Date(timeIntervalSince1970: 86_400)
        let dto = try OpenMeteoPollenSDKClient.aggregateHourlyResponse(
            coordinate: coordinate,
            generatedAt: generatedAt,
            hourlyDates: [
                firstDay,
                firstDay.addingTimeInterval(3_600),
                secondDay,
                secondDay.addingTimeInterval(3_600)
            ],
            hourlyVariables: [
                (pollenType: .birch, values: [1, 11, 7, 20]),
                (pollenType: .grass, values: [3, 4, 40, 18])
            ]
        )

        #expect(dto.coordinate == coordinate)
        #expect(dto.generatedAt == generatedAt)
        #expect(dto.daily.dates == [firstDay, secondDay])
        #expect(dto.daily.variables == [
            OpenMeteoPollenResponseDTO.DailyVariable(pollenType: .birch, values: [11, 20]),
            OpenMeteoPollenResponseDTO.DailyVariable(pollenType: .grass, values: [4, 40])
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

    private func isoDate(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
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
