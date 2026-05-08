import SwiftUI

#if DEBUG
#Preview("Allergien im Blick") {
    AppCompositionRoot.demo().makeRootView(
        launchConfiguration: .screenshot(.dashboard),
        telemetryService: AppTelemetryService()
    )
}

#Preview("Symptom erfassen") {
    AppCompositionRoot.demo().makeRootView(
        launchConfiguration: .screenshot(.entry),
        telemetryService: AppTelemetryService()
    )
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
