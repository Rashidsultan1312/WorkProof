import Foundation

enum CurrencySettings {
    static let storageKey = "selectedCurrencyCode"
    static let defaultCode = "RUB"

    static var selectedCurrencyCode: String {
        get {
            let value = UserDefaults.standard.string(forKey: storageKey) ?? defaultCode
            return CurrencyOption(rawValue: value)?.rawValue ?? defaultCode
        }
        set {
            let normalized = CurrencyOption(rawValue: newValue)?.rawValue ?? defaultCode
            UserDefaults.standard.set(normalized, forKey: storageKey)
        }
    }
}

enum CurrencyOption: String, CaseIterable, Identifiable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case kzt = "KZT"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rub:
            return "Russian Ruble"
        case .usd:
            return "US Dollar"
        case .eur:
            return "Euro"
        case .gbp:
            return "British Pound"
        case .kzt:
            return "Kazakhstani Tenge"
        }
    }

    var symbol: String {
        switch self {
        case .rub:
            return "₽"
        case .usd:
            return "$"
        case .eur:
            return "€"
        case .gbp:
            return "£"
        case .kzt:
            return "₸"
        }
    }
}
