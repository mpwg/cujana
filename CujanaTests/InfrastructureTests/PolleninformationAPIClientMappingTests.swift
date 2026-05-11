import Foundation
import polleninformation
import Testing
@testable import Cujana

struct PolleninformationAPIClientMappingTests {

    @Test func mapsPackageForecastAndAdditionalAllergyRisk() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = try #require(isoDate("2026-05-07T08:00:00Z"))
        let startDate = try #require(isoDate("2026-05-08T00:00:00Z"))
        let endDate = try #require(isoDate("2026-05-09T00:00:00Z"))
        let dto = try await PolleninformationURLSessionClient.makeResponse(
            client: FullForecastClient(),
            context: PolleninformationResponseContext(
                coordinate: coordinate,
                country: .austria,
                language: .german,
                calendar: calendar,
                generatedAt: generatedAt,
                startDate: startDate,
                endDate: endDate
            )
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

    @Test func mapsMissingLocationPayloadToNoInformationForLocation() async throws {
        let coordinate = try LocationCoordinate(latitude: 37.75, longitude: -122.4)
        let generatedAt = try #require(isoDate("2026-05-07T08:00:00Z"))
        let startDate = try #require(isoDate("2026-05-08T00:00:00Z"))
        let endDate = try #require(isoDate("2026-05-09T00:00:00Z"))
        let dto = try await PolleninformationURLSessionClient.makeResponse(
            client: MissingPayloadClient(),
            context: PolleninformationResponseContext(
                coordinate: coordinate,
                country: .austria,
                language: .german,
                calendar: calendar,
                generatedAt: generatedAt,
                startDate: startDate,
                endDate: endDate
            )
        )

        #expect(dto.coordinate == coordinate)
        #expect(dto.daily.dates == [
            try #require(isoDate("2026-05-08T00:00:00Z")),
            try #require(isoDate("2026-05-09T00:00:00Z"))
        ])
        #expect(dto.daily.variables.isEmpty)
        #expect(dto.dailyAllergyRisks.isEmpty)
    }

    @Test func mapsGenericDecodingErrorToDecodingFailure() async throws {
        let coordinate = try LocationCoordinate(latitude: 37.75, longitude: -122.4)
        let generatedAt = try #require(isoDate("2026-05-07T08:00:00Z"))
        let startDate = try #require(isoDate("2026-05-08T00:00:00Z"))
        let endDate = try #require(isoDate("2026-05-09T00:00:00Z"))

        await #expect(throws: PollenDataError.decodingFailed) {
            try await PolleninformationURLSessionClient.makeResponse(
                client: MissingRiskClient(),
                context: PolleninformationResponseContext(
                    coordinate: coordinate,
                    country: .austria,
                    language: .german,
                    calendar: calendar,
                    generatedAt: generatedAt,
                    startDate: startDate,
                    endDate: endDate
                )
            )
        }
    }

    @Test func rejectsShortDailyValueArrays() throws {
        #expect(throws: PollenDataError.decodingFailed) {
            try PolleninformationURLSessionClient.values(
                from: [4],
                offsets: [0, 1],
                fieldName: "contamination.dailyValues"
            )
        }
    }

    @Test func ignoresUnknownContaminationTypes() async throws {
        let coordinate = try LocationCoordinate(latitude: 48.2082, longitude: 16.3738)
        let generatedAt = try #require(isoDate("2026-05-07T08:00:00Z"))
        let dto = try await PolleninformationURLSessionClient.makeResponse(
            client: UnknownContaminationClient(),
            context: PolleninformationResponseContext(
                coordinate: coordinate,
                country: .austria,
                language: .german,
                calendar: calendar,
                generatedAt: generatedAt,
                startDate: generatedAt,
                endDate: generatedAt
            )
        )

        #expect(dto.daily.variables.isEmpty)
        #expect(dto.dailyAllergyRisks.map(\.value) == [8])
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func isoDate(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }
}

private struct FullForecastClient: PolleninformationForecastLoading {
    func forecast(
        country: CountryCode,
        language: LanguageCode,
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse {
        ForecastResponse(
            contamination: [
                PollenContamination(
                    pollID: 1,
                    pollTitle: "Birke",
                    today: 4,
                    tomorrow: 3,
                    inTwoDays: 2,
                    inThreeDays: 1
                ),
                PollenContamination(
                    pollID: 2,
                    pollTitle: "Gräser",
                    today: 2,
                    tomorrow: 1,
                    inTwoDays: 0,
                    inThreeDays: 0
                ),
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

private struct MissingPayloadClient: PolleninformationForecastLoading {
    func forecast(
        country: CountryCode,
        language: LanguageCode,
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse {
        throw PolleninformationError.decoding("no payload for coordinate")
    }
}

private struct MissingRiskClient: PolleninformationForecastLoading {
    func forecast(
        country: CountryCode,
        language: LanguageCode,
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse {
        throw PolleninformationError.decoding("No value associated with key allergyrisk.")
    }
}

private struct UnknownContaminationClient: PolleninformationForecastLoading {
    func forecast(
        country: CountryCode,
        language: LanguageCode,
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse {
        ForecastResponse(
            contamination: [
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
