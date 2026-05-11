import SwiftUI

struct EntryListContent: Equatable {
    let title: String
    let subtitle: String
    let sections: [EntryListDaySection]
    let generatedAtText: String
}

struct EntryListDaySection: Identifiable, Equatable {
    let id: String
    let title: String
    let entries: [JournalEntryItem]
}

struct JournalEntryItem: Identifiable, Equatable {
    let id: String
    let dateText: String
    let timeText: String
    let severityText: String
    let noteText: String?
    let contextText: String?
    let contextSystemImageName: String
    let symptoms: [JournalEntrySymptomItem]
    let severityBackground: Color
}

struct JournalEntrySymptomItem: Identifiable, Equatable {
    let type: SymptomType
    let title: String
    let background: Color

    var id: SymptomType {
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
