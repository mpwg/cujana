import Foundation
import polleninformation
import Testing
@testable import Cujana

struct PolleninformationPollenTests {

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
                  3
                ]
              }
            ]
          },
          "dailyAllergyRisks": [
            {
              "date": "2026-05-07T00:00:00Z",
              "value": 8,
              "hourlyValues": [1, 4, 8]
            }
          ]
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dto = try decoder.decode(PolleninformationPollenResponseDTO.self, from: Data(json.utf8))

        #expect(dto.coordinate == (try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)))
        #expect(dto.daily.dates == [try #require(isoDate("2026-05-07T00:00:00Z"))])
        #expect(dto.daily.variables == [
            PolleninformationPollenResponseDTO.DailyVariable(pollenType: .birch, values: [3])
        ])
        #expect(dto.dailyAllergyRisks.first?.value == 8)
    }

    @Test func mapperCreatesDomainForecastFromDailyPollenValuesAndAllergyRisk() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = Date(timeIntervalSince1970: 500)
        let firstDate = Date(timeIntervalSince1970: 0)
        let secondDate = Date(timeIntervalSince1970: 86_400)
        let dto = PolleninformationPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: generatedAt,
            daily: PolleninformationPollenResponseDTO.Daily(
                dates: [firstDate, secondDate],
                variables: [
                    PolleninformationPollenResponseDTO.DailyVariable(
                        pollenType: .birch,
                        values: [0, 3]
                    ),
                    PolleninformationPollenResponseDTO.DailyVariable(
                        pollenType: .grass,
                        values: [4, 1]
                    )
                ]
            ),
            dailyAllergyRisks: [
                PolleninformationPollenResponseDTO.DailyAllergyRisk(
                    date: firstDate,
                    value: 1,
                    hourlyValues: [0, 3, 6]
                )
            ]
        )

        let forecasts = try PolleninformationPollenMapper.map(dto)

        #expect(forecasts.count == 1)
        #expect(forecasts[0].coordinate == coordinate)
        #expect(forecasts[0].generatedAt == generatedAt)
        #expect(forecasts[0].validFrom == firstDate)
        #expect(forecasts[0].validUntil == secondDate)
        #expect(forecasts[0].dailyLevels == [
            PollenForecast.DailyLevel(date: firstDate, pollenType: .birch, level: .none),
            PollenForecast.DailyLevel(date: secondDate, pollenType: .birch, level: .high),
            PollenForecast.DailyLevel(date: firstDate, pollenType: .grass, level: .veryHigh),
            PollenForecast.DailyLevel(date: secondDate, pollenType: .grass, level: .low)
        ])
        #expect(forecasts[0].dailyAllergyRisks == [
            PollenForecast.DailyAllergyRisk(
                date: firstDate,
                level: .low,
                hourlyLevels: [.none, .moderate, .high]
            )
        ])
    }

    @Test func mapperReturnsNoForecastWhenDailyDatesAreEmpty() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let dto = PolleninformationPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: Date(timeIntervalSince1970: 0),
            daily: PolleninformationPollenResponseDTO.Daily(
                dates: [],
                variables: [
                    PolleninformationPollenResponseDTO.DailyVariable(
                        pollenType: .birch,
                        values: [4]
                    )
                ]
            )
        )

        let forecasts = try PolleninformationPollenMapper.map(dto)

        #expect(forecasts.isEmpty)
    }

    @Test func mapperIgnoresPollenValuesWithoutMatchingDate() throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let date = Date(timeIntervalSince1970: 0)
        let dto = PolleninformationPollenResponseDTO(
            coordinate: coordinate,
            generatedAt: date,
            daily: PolleninformationPollenResponseDTO.Daily(
                dates: [date],
                variables: [
                    PolleninformationPollenResponseDTO.DailyVariable(
                        pollenType: .grass,
                        values: [2, 4]
                    )
                ]
            )
        )

        let forecasts = try PolleninformationPollenMapper.map(dto)

        #expect(forecasts.first?.dailyLevels == [
            PollenForecast.DailyLevel(date: date, pollenType: .grass, level: .moderate)
        ])
    }

    @Test func apiClientMapsPackageForecastAndAdditionalAllergyRisk() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = try #require(isoDate("2026-05-07T08:00:00Z"))
        let startDate = try #require(isoDate("2026-05-08T00:00:00Z"))
        let endDate = try #require(isoDate("2026-05-09T00:00:00Z"))
        let dto = try await PolleninformationURLSessionClient.makeResponse(
            client: FakePolleninformationForecastClient(),
            coordinate: coordinate,
            country: .austria,
            language: .german,
            calendar: calendar,
            generatedAt: generatedAt,
            startDate: startDate,
            endDate: endDate
        )

        #expect(dto.daily.dates == [
            try #require(isoDate("2026-05-08T00:00:00Z")),
            try #require(isoDate("2026-05-09T00:00:00Z"))
        ])
        #expect(dto.daily.variables == [
            PolleninformationPollenResponseDTO.DailyVariable(pollenType: .birch, values: [3, 2]),
            PolleninformationPollenResponseDTO.DailyVariable(pollenType: .grass, values: [1, 0])
        ])
        #expect(dto.dailyAllergyRisks.map(\.value) == [7, 6])
        #expect(dto.dailyAllergyRisks.map(\.hourlyValues) == [[4, 7], [3, 6]])
    }

    @Test func repositoryLoadsForecastsThroughInjectedAPIClient() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let date = Date(timeIntervalSince1970: 0)
        let cache = PolleninformationPollenResponseCache(userDefaults: testDefaults(), storageKey: "repository-load")
        await cache.removeAll()
        let apiClient = FakePolleninformationPollenAPIClient(
            response: PolleninformationPollenResponseDTO(
                coordinate: coordinate,
                generatedAt: date,
                daily: PolleninformationPollenResponseDTO.Daily(
                    dates: [date],
                    variables: [
                        PolleninformationPollenResponseDTO.DailyVariable(
                            pollenType: .ragweed,
                            values: [2]
                        )
                    ]
                )
            )
        )
        let repository = PolleninformationPollenRepository(apiClient: apiClient, cache: cache)

        let forecasts = try await repository.pollenForecast(
            for: coordinate,
            from: date,
            to: date
        )

        #expect(forecasts.first?.dailyLevels == [
            PollenForecast.DailyLevel(date: date, pollenType: .ragweed, level: .moderate)
        ])
    }

    @Test func repositoryUsesCachedResponseWithinFairUseWindow() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let date = Date(timeIntervalSince1970: 0)
        let cache = PolleninformationPollenResponseCache(userDefaults: testDefaults(), storageKey: "repository-cache")
        await cache.removeAll()
        await cache.store(
            PolleninformationPollenResponseDTO(
                coordinate: coordinate,
                generatedAt: date,
                daily: PolleninformationPollenResponseDTO.Daily(
                    dates: [date],
                    variables: [
                        PolleninformationPollenResponseDTO.DailyVariable(pollenType: .birch, values: [4])
                    ]
                )
            ),
            for: coordinate
        )
        let repository = PolleninformationPollenRepository(
            apiClient: FailingPolleninformationPollenAPIClient(),
            cache: cache,
            now: { date.addingTimeInterval(60 * 60) }
        )

        let forecasts = try await repository.pollenForecast(for: coordinate, from: date, to: date)

        #expect(forecasts.first?.dailyLevels == [
            PollenForecast.DailyLevel(date: date, pollenType: .birch, level: .veryHigh)
        ])
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func isoDate(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }

    private func testDefaults() -> UserDefaults {
        UserDefaults(suiteName: "PolleninformationPollenTests") ?? .standard
    }
}

private struct FakePolleninformationForecastClient: PolleninformationForecastLoading {
    func forecast(
        country: CountryCode,
        language: LanguageCode,
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse {
        ForecastResponse(
            contamination: [
                PollenContamination(pollID: 1, pollTitle: "Birke", today: 4, tomorrow: 3, inTwoDays: 2, inThreeDays: 1),
                PollenContamination(pollID: 2, pollTitle: "Gräser", today: 2, tomorrow: 1, inTwoDays: 0, inThreeDays: 0),
                PollenContamination(
                    pollID: 23,
                    pollTitle: "Pilzsporen (Alternaria)",
                    today: 4,
                    tomorrow: 4,
                    inTwoDays: 4,
                    inThreeDays: 4
                )
            ],
            allergyRisk: AllergyRisk(today: 8, tomorrow: 7, inTwoDays: 6, inThreeDays: 5),
            hourlyAllergyRisk: HourlyAllergyRisk(
                today: [5, 8],
                tomorrow: [4, 7],
                inTwoDays: [3, 6],
                inThreeDays: [2, 5]
            )
        )
    }
}

private struct FakePolleninformationPollenAPIClient: PolleninformationPollenAPIClient {
    let response: PolleninformationPollenResponseDTO

    func pollenResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> PolleninformationPollenResponseDTO {
        response
    }
}

private struct FailingPolleninformationPollenAPIClient: PolleninformationPollenAPIClient {
    func pollenResponse(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> PolleninformationPollenResponseDTO {
        throw PollenDataError.networkFailure
    }
}
