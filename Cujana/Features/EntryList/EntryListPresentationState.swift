import SwiftUI

struct EntryListContent: Equatable {
    let sections: [EntryListDaySection]
}

struct EntryListDaySection: Identifiable, Equatable {
    let id: String
    let title: String
    let entries: [JournalEntryItem]
}

struct JournalEntryItem: Identifiable, Equatable {
    let id: String
    let entry: HealthEntry
    let timeText: String
    let noteText: String?
    let contextText: String
    let contextSystemImageName: String
    let symptoms: [JournalEntrySymptomItem]
}

struct JournalEntrySymptomItem: Identifiable, Equatable {
    let type: SymptomType
    let title: String
    let background: Color
    let foreground: Color

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
