enum EventScene {
    case main(MainScene? = nil)

    var label: String {
        switch self {
        case .main: return "Main"
        }
    }

    var objetLabel: String? {
        switch self {
        case let .main(mainScene): return mainScene?.rawValue
        }
    }
}
