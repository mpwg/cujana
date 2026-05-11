import Foundation

@MainActor
protocol SymptomEntryChangePublishing: AnyObject {
    func publish(_ change: SymptomEntryChange)
}

@MainActor
protocol SymptomEntryChangeObserving: AnyObject {
    var changes: AsyncStream<SymptomEntryChange> { get }
}

@MainActor
final class SymptomEntryChangeStore: SymptomEntryChangePublishing, SymptomEntryChangeObserving {
    private var continuations: [UUID: AsyncStream<SymptomEntryChange>.Continuation] = [:]

    var changes: AsyncStream<SymptomEntryChange> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.continuations.removeValue(forKey: id)
                }
            }
        }
    }

    func publish(_ change: SymptomEntryChange) {
        for continuation in continuations.values {
            continuation.yield(change)
        }
    }
}
