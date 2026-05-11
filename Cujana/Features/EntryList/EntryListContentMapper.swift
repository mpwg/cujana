import Foundation

struct EntryListContentMapper {
    private enum Constant {
        static let visiblePollenCount = 4
        static let germanLocale = Locale(identifier: "de_AT")
    }

    private let calendar: Calendar

    init(calendar: Calendar) {
        self.calendar = calendar
    }

    func makeContent(entries: [AllergySymptomEntry], pollenForecasts: [PollenForecast]) -> EntryListContent {
        EntryListContent(
            sections: makeSections(entries: entries, pollenForecasts: pollenForecasts)
        )
    }
}

private extension EntryListContentMapper {
    func makeSections(
        entries: [AllergySymptomEntry],
        pollenForecasts: [PollenForecast]
    ) -> [EntryListDaySection] {
        let groupedByDay = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return groupedByDay.keys
            .sorted(by: >)
            .map { day in
                EntryListDaySection(
                    id: day.ISO8601Format(),
                    title: sectionTitle(for: day),
                    entries: entriesForDay(day, in: groupedByDay, pollenForecasts: pollenForecasts)
                )
            }
    }

    func entriesForDay(
        _ day: Date,
        in groupedByDay: [Date: [AllergySymptomEntry]],
        pollenForecasts: [PollenForecast]
    ) -> [JournalEntryItem] {
        groupedByDay[day, default: []]
            .sorted { $0.date > $1.date }
            .map { entry in
                makeItem(from: entry, pollenForecasts: pollenForecasts)
            }
    }

    func makeItem(from entry: HealthEntry, pollenForecasts: [PollenForecast]) -> JournalEntryItem {
        JournalEntryItem(
            id: entry.id.uuidString,
            entry: entry,
            timeText: entry.date.formatted(.dateTime.hour().minute()),
            noteText: entry.note,
            contextText: contextText(for: entry, pollenForecasts: pollenForecasts),
            contextSystemImageName: "cloud.sun",
            symptoms: entry.symptoms.map { symptom in
                JournalEntrySymptomItem(
                    type: symptom,
                    title: AllergyDashboardPresentationState.title(for: symptom),
                    background: EntryListToken.symptomBackground(for: entry.severity),
                    foreground: EntryListToken.symptomForeground(for: entry.severity)
                )
            }
        )
    }

    func contextText(for entry: HealthEntry, pollenForecasts: [PollenForecast]) -> String {
        ([severityContextText(for: entry.severity)] + pollenContextItems(for: entry.date, in: pollenForecasts))
            .joined(separator: " · ")
    }

    func pollenContextItems(for date: Date, in pollenForecasts: [PollenForecast]) -> [String] {
        pollenForecasts
            .flatMap(\.dailyLevels)
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .filter { $0.level.rawValue > PollenLevel.none.rawValue }
            .sorted(by: sortDailyLevel)
            .prefix(Constant.visiblePollenCount)
            .map(pollenContextText)
    }

    func sortDailyLevel(first: PollenForecast.DailyLevel, second: PollenForecast.DailyLevel) -> Bool {
        if first.level == second.level {
            return AllergyDashboardPresentationState.title(for: first.pollenType)
                < AllergyDashboardPresentationState.title(for: second.pollenType)
        }

        return first.level > second.level
    }

    func sectionTitle(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Heute"
        }

        if calendar.isDateInYesterday(date) {
            return "Gestern"
        }

        return date.formatted(
            .dateTime
                .weekday(.wide)
                .day()
                .month(.wide)
                .locale(Constant.germanLocale)
        )
    }

    func severityContextText(for severity: SymptomSeverity) -> String {
        switch severity.rawValue {
        case 0...3:
            "Mild"
        case 4...6:
            "Mittel"
        default:
            "Stark"
        }
    }

    func pollenContextText(for level: PollenForecast.DailyLevel) -> String {
        let title = AllergyDashboardPresentationState.title(for: level.pollenType)
        return "\(pollenContextPrefix(for: level.level)) \(title)belastung"
    }

    func pollenContextPrefix(for level: PollenLevel) -> String {
        switch level.rawValue {
        case 1:
            "Niedrige"
        case 2:
            "Mittlere"
        case 3:
            "Hohe"
        default:
            "Sehr hohe"
        }
    }
}
