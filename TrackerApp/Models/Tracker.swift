import Foundation

struct Tracker: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let emoji: String
    let color: TrackerColor
    let schedule: Set<WeekDay>
}
