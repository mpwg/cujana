import SwiftUI

struct ContentView: View {
    @State private var viewModel: SymptomEntryViewModel

    init(viewModel: SymptomEntryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        SymptomEntryView(viewModel: viewModel)
    }
}

#Preview {
    let repository = InMemorySymptomEntryRepository()
    let useCase = SaveAllergySymptomEntryUseCase(repository: repository)

    ContentView(viewModel: SymptomEntryViewModel(saveUseCase: useCase))
}
