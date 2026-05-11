import Foundation

final class UserDefaultsUsageDataConsentStore: UsageDataConsentStoring {
    private let defaults: UserDefaults
    private let consentKey = "usageDataCollectionAllowed"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var consent: UsageDataConsent {
        guard defaults.object(forKey: consentKey) != nil else {
            return .undecided
        }

        return defaults.bool(forKey: consentKey) ? .allowed : .denied
    }

    func setConsent(_ consent: UsageDataConsent) {
        switch consent {
        case .undecided:
            defaults.removeObject(forKey: consentKey)
        case .allowed:
            defaults.set(true, forKey: consentKey)
        case .denied:
            defaults.set(false, forKey: consentKey)
        }
    }
}
