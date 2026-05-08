import SwiftUI

#if DEBUG
#Preview("Allergien im Blick") {
    AppCompositionRoot.demo().makeRootView(launchConfiguration: .screenshot(.dashboard))
}

#Preview("Symptom erfassen") {
    AppCompositionRoot.demo().makeRootView(launchConfiguration: .screenshot(.entry))
}

#Preview("Dashboard") {
    AllergyDashboardView(
        viewModel: AppDemoData.makeDashboardViewModel(),
        onStartSymptomEntry: {}
    )
}

#Preview("Symptome") {
    SymptomEntryView(viewModel: AppDemoData.makeSymptomEntryViewModel())
}
#endif
