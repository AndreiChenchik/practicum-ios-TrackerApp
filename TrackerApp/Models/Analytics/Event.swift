enum Event {
    case open(EventScene)
    case close(EventScene)
    case tap(EventScene)

    var label: String {
        switch self {
        case .open: return "open"
        case .close: return "close"
        case .tap: return "click"
        }
    }
}
