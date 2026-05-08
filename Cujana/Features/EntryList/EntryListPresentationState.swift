import SwiftUI

struct EntryListContent: Equatable {
    let title: String
    let subtitle: String
    let items: [EntryListItem]
    let generatedAtText: String
}

struct EntryListItem: Identifiable, Equatable {
    let id: UUID
    let dateText: String
    let timeText: String
    let symptomTitle: String
    let severityText: String
    let noteText: String?
    let weatherTitle: String
    let weatherDescription: String
    let pollenItems: [EntryListPollenItem]
    let symptomSystemImageName: String
    let symptomBackground: Color
}

struct EntryListPollenItem: Identifiable, Equatable {
    let type: PollenType
    let title: String
    let levelText: String
    let background: Color

    var id: PollenType {
        type
    }
}

enum EntryListState: Equatable {
    case idle
    case loading
    case empty(EntryListContent)
    case loaded(EntryListContent)
    case failure(String)
}
