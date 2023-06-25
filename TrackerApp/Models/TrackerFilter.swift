import Foundation

enum TrackerFilter: CaseIterable {
    case all, today, done, notDone
}

extension TrackerFilter {
    var label: String {
        switch self {
        case .all:
            return NSLocalizedString("trackers.filter.all", comment: "Filter: display all")
        case .today:
            return NSLocalizedString("trackers.filter.today", comment: "Filter: display today")
        case .done:
            return NSLocalizedString("trackers.filter.done", comment: "Filter: display done")
        case .notDone:
            return NSLocalizedString("trackers.filter.notDone", comment: "Filter: display not done")
        }
    }
}
