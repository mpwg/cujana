import Foundation

#if DEBUG
enum AppDemoData {
    static let now = makeDate(year: 2026, month: 5, day: 8, hour: 9, minute: 41)
    static let calendar = Calendar(identifier: .gregorian)

    static var coordinate: LocationCoordinate {
        guard let coordinate = try? LocationCoordinate(latitude: 48.2082, longitude: 16.3738) else {
            fatalError("Demo coordinate must be valid.")
        }

        return coordinate
    }

    static var symptomEntries: [AllergySymptomEntry] {
        [
            makeSymptomEntry(
                seed: SymptomEntrySeed(
                    id: "4F3D9A01-6F70-4B50-8ED8-10F7B63D0F51",
                    daysOffset: 0,
                    hour: 7,
                    minute: 25,
                    symptoms: [.itchyEyes, .coughing, .headache],
                    severity: .moderate,
                    note: "Nach dem Weg durch den Park deutlich stärker."
                )
            ),
            makeSymptomEntry(
                seed: SymptomEntrySeed(
                    id: "18259AE3-A2CF-49ED-A3A4-5D3E86A24D8D",
                    daysOffset: -1,
                    hour: 21,
                    minute: 10,
                    symptoms: [.blockedNose],
                    severity: .mild,
                    note: "Fenster am Abend länger offen gelassen."
                )
            ),
            makeSymptomEntry(
                seed: SymptomEntrySeed(
                    id: "9069639C-18D6-4577-86BD-10A8D254679F",
                    daysOffset: -2,
                    hour: 16,
                    minute: 40,
                    symptoms: [.sneezing],
                    severity: .severe,
                    note: "Nach Rasenmähen im Innenhof."
                )
            )
        ]
    }

    static var pollenForecasts: [PollenForecast] {
        [
            makePollenForecast(
                id: "47913F00-C740-41FB-A3EF-EF5BB8E45295",
                levels: [
                    (.grass, .high),
                    (.birch, .moderate),
                    (.rye, .moderate),
                    (.oak, .low),
                    (.ragweed, .none)
                ]
            )
        ]
    }

    static var weatherForecasts: [WeatherForecast] {
        [
            WeatherForecast(
                coordinate: coordinate,
                generatedAt: now,
                dailyConditions: [
                    WeatherForecast.DailyCondition(
                        date: now,
                        temperature: 22,
                        conditionCode: 3,
                        humidityPercent: 54,
                        windSpeedKilometersPerHour: 12
                    ),
                    WeatherForecast.DailyCondition(
                        date: makeRelativeDate(daysOffset: 1, hour: 9, minute: 41),
                        temperature: 19,
                        conditionCode: 61,
                        humidityPercent: 68,
                        windSpeedKilometersPerHour: 18
                    ),
                    WeatherForecast.DailyCondition(
                        date: makeRelativeDate(daysOffset: 2, hour: 9, minute: 41),
                        temperature: 21,
                        conditionCode: 2,
                        humidityPercent: 49,
                        windSpeedKilometersPerHour: 10
                    )
                ]
            )
        ]
    }

    static func makeSymptomEntryViewModel() -> SymptomEntryViewModel {
        let viewModel = SymptomEntryViewModel(
            saveUseCase: SaveAllergySymptomEntryUseCase(
                repository: DemoSymptomEntryRepository(entries: symptomEntries)
            )
        )
        viewModel.selectedSymptoms = [.itchyEyes]
        viewModel.selectedSeverityLevel = 3
        viewModel.entryDate = now
        viewModel.note = "Augen jucken seit dem Heimweg durch den Park."
        return viewModel
    }

    static func makeDashboardViewModel() -> AllergyDashboardViewModel {
        AllergyDashboardViewModel(
            loadUseCase: LoadAllergyOverviewUseCase(
                pollenRepository: DemoPollenRepository(forecasts: pollenForecasts),
                weatherRepository: DemoWeatherRepository(forecasts: weatherForecasts),
                symptomEntryRepository: DemoSymptomEntryRepository(entries: symptomEntries)
            ),
            coordinate: coordinate,
            calendar: calendar
        )
    }

    static func makeEntryListViewModel() -> EntryListViewModel {
        EntryListViewModel(
            loadEntriesUseCase: LoadAllergySymptomEntriesUseCase(
                repository: DemoSymptomEntryRepository(entries: symptomEntries)
            ),
            saveEntryUseCase: SaveAllergySymptomEntryUseCase(
                repository: DemoSymptomEntryRepository(entries: symptomEntries)
            ),
            deleteEntryUseCase: DeleteAllergySymptomEntryUseCase(
                repository: DemoSymptomEntryRepository(entries: symptomEntries)
            ),
            loadPollenUseCase: LoadPollenForecastUseCase(
                repository: DemoPollenRepository(forecasts: pollenForecasts)
            ),
            coordinate: coordinate,
            calendar: calendar
        )
    }

    private static func makePollenForecast(
        id: String,
        levels: [(PollenType, PollenLevel)]
    ) -> PollenForecast {
        do {
            return try PollenForecast(
                id: UUID(uuidString: id) ?? UUID(),
                coordinate: coordinate,
                sourceKind: .forecast,
                generatedAt: now,
                validFrom: now,
                validUntil: makeDate(year: 2026, month: 5, day: 11, hour: 9, minute: 41),
                dailyLevels: levels.map { type, level in
                    PollenForecast.DailyLevel(date: now, pollenType: type, level: level)
                }
            )
        } catch {
            fatalError("Demo pollen forecast must be valid.")
        }
    }

    private struct SymptomEntrySeed {
        let id: String
        let daysOffset: Int
        let hour: Int
        let minute: Int
        let symptoms: [SymptomType]
        let severity: SymptomSeverity
        let note: String

        init(
            id: String,
            daysOffset: Int,
            hour: Int,
            minute: Int,
            symptoms: [SymptomType],
            severity: SymptomSeverity,
            note: String
        ) {
            self.id = id
            self.daysOffset = daysOffset
            self.hour = hour
            self.minute = minute
            self.symptoms = symptoms
            self.severity = severity
            self.note = note
        }
    }

    private static func makeSymptomEntry(seed: SymptomEntrySeed) -> AllergySymptomEntry {
        do {
            return try AllergySymptomEntry(
                id: UUID(uuidString: seed.id) ?? UUID(),
                date: makeRelativeDate(daysOffset: seed.daysOffset, hour: seed.hour, minute: seed.minute),
                symptoms: seed.symptoms,
                severity: seed.severity,
                note: seed.note,
                coordinate: coordinate
            )
        } catch {
            fatalError("Demo symptom entry must be valid.")
        }
    }

    private static func makeRelativeDate(daysOffset: Int, hour: Int, minute: Int) -> Date {
        let day = calendar.date(byAdding: .day, value: daysOffset, to: now) ?? now
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: day
        ) ?? day
    }

    private static func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = TimeZone(identifier: "Europe/Vienna")
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute

        guard let date = components.date else {
            fatalError("Demo date must be valid.")
        }

        return date
    }
}

actor DemoSymptomEntryRepository: SymptomEntryRepository {
    private var entries: [AllergySymptomEntry]

    init(entries: [AllergySymptomEntry]) {
        self.entries = entries
    }

    func save(_ entry: AllergySymptomEntry) async throws {
        if let existingIndex = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[existingIndex] = entry
        } else {
            entries.append(entry)
        }
    }

    func delete(id: UUID) async throws {
        entries.removeAll { $0.id == id }
    }

    func symptomEntries(from startDate: Date, to endDate: Date) async throws -> [AllergySymptomEntry] {
        entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }
}

struct DemoPollenRepository: PollenRepository {
    private let forecasts: [PollenForecast]

    init(forecasts: [PollenForecast]) {
        self.forecasts = forecasts
    }

    func pollenForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [PollenForecast] {
        forecasts
    }
}

struct DemoWeatherRepository: WeatherRepository {
    private let forecasts: [WeatherForecast]

    init(forecasts: [WeatherForecast]) {
        self.forecasts = forecasts
    }

    func weatherForecast(
        for coordinate: LocationCoordinate,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherForecast] {
        forecasts
    }
}
#endif
