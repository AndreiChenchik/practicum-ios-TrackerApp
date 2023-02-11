import Foundation
import Combine

protocol TrackerStoring {
    var completedTrackers: [Date: Set<TrackerRecord>] { get set }
    var categories: [TrackerCategory] { get set }
    var objectWillChange: ObservableObjectPublisher { get }
}

final class TrackerRepository: ObservableObject {
    @Published var completedTrackers: [Date: Set<TrackerRecord>] = [:]
    @Published var categories: [TrackerCategory] = []
}

extension TrackerRepository: TrackerStoring {}
