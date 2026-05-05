//
//  ContentView.swift
//  Cujana
//
//  Created by Matthias Wallner-Géhri on 04.05.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpacingToken.section) {
                    header

                    VStack(alignment: .leading, spacing: SpacingToken.lg) {
                        if items.isEmpty {
                            EmptyJournalView(addItem: addItem)
                        } else {
                            ForEach(items) { item in
                                JournalEntryRow(item: item) {
                                    modelContext.delete(item)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, SpacingToken.xl)
                .padding(.vertical, SpacingToken.xl)
            }
            .background(ColorToken.backgroundPrimary)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorToken.backgroundPrimary, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: addButtonPlacement) {
                    Button(action: addItem) {
                        Image(systemName: "plus")
                            .font(TypographyToken.bodyEmphasized)
                            .foregroundStyle(ColorToken.brandPrimary)
                            .padding(SpacingToken.sm)
                            .background(ColorToken.fillSubtle)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Eintrag hinzufügen")
                }
            }
        }
    }

    private var addButtonPlacement: ToolbarItemPlacement {
#if os(iOS)
        .topBarTrailing
#else
        .automatic
#endif
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SpacingToken.md) {
            Text("Cujana")
                .font(TypographyToken.largeTitle)
                .foregroundStyle(ColorToken.textPrimary)

            Text("Ruhige Tagesnotizen für Symptome, Energie und Kontext.")
                .font(TypographyToken.body)
                .foregroundStyle(ColorToken.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: SpacingToken.sm) {
                Text("Heute")
                    .cujanaChip(isSelected: true)

                Text("\(items.count) Einträge")
                    .cujanaChip()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

private struct EmptyJournalView: View {
    let addItem: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.lg) {
            VStack(alignment: .leading, spacing: SpacingToken.sm) {
                Text("Noch kein Eintrag")
                    .font(TypographyToken.headline)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Starte mit einem sanften Check-in und halte fest, was heute relevant ist.")
                    .font(TypographyToken.body)
                    .foregroundStyle(ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: addItem) {
                Label("Ersten Eintrag erstellen", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .cujanaCard()
    }
}

private struct JournalEntryRow: View {
    let item: Item
    let delete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.md) {
            Circle()
                .fill(ColorToken.brandAccent)
                .frame(width: SpacingToken.sm, height: SpacingToken.sm)
                .padding(.top, SpacingToken.sm)

            VStack(alignment: .leading, spacing: SpacingToken.xs) {
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(TypographyToken.bodyEmphasized)
                    .foregroundStyle(ColorToken.textPrimary)

                Text("Kurzer Check-in gespeichert")
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.textSecondary)
            }

            Spacer(minLength: SpacingToken.md)

            Button(action: delete) {
                Image(systemName: "trash")
                    .font(TypographyToken.footnote)
                    .foregroundStyle(ColorToken.feedbackError)
                    .padding(SpacingToken.sm)
                    .background(ColorToken.fillSubtle)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Eintrag löschen")
        }
        .cujanaCard()
    }
}
