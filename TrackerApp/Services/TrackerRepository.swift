import Foundation
import Combine

typealias FilteredTrackers = [(category: TrackerCategory, trackers: [Tracker])]

protocol TrackerStoring {
    func addCategory(_ category: TrackerCategory)
    func addTracker(_ tracker: Tracker, toCategory id: UUID)
    func markTrackerComplete(id: UUID, on date: Date)

    func filtered(at date: Date, with searchText: String) -> FilteredTrackers

    var categoriesPublisher: Published<[TrackerCategory]>.Publisher { get }
    var objectWillChange: ObservableObjectPublisher { get }
}

final class TrackerRepository: ObservableObject {
    @Published var completedTrackers: [String: Set<TrackerRecord>] = [:]
    @Published var categories: [TrackerCategory] = [.mockHome, .mockSmallThings, .mockSmallThings2]

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    
}

extension TrackerRepository: TrackerStoring {
    var categoriesPublisher: Published<[TrackerCategory]>.Publisher { $categories }

    // MARK: - Creation

    func addCategory(_ category: TrackerCategory) {
        var newCategories = categories
        newCategories.append(category)
        categories = newCategories
    }

    func addTracker(_ tracker: Tracker, toCategory id: UUID) {
        var newCategories = categories

        guard let index = newCategories.firstIndex(where: { $0.id == id }) else {
            assertionFailure("Can't find category")
            return
        }

        let existingCategory = newCategories[index]
        var trackers = existingCategory.trackers
        trackers.append(tracker)

        let newCategory = TrackerCategory(label: existingCategory.label, trackers: trackers)
        newCategories[index] = newCategory

        categories = newCategories
    }

    // MARK: - Data

    func filtered(at date: Date, with searchText: String) -> FilteredTrackers {
        guard let selectedWeekday = WeekDay(
            rawValue: Calendar.current.component(.weekday, from: date)
        ) else { preconditionFailure("Weekday must be in range of 1...7") }

        let emptySearch = searchText.isEmpty
        var result = FilteredTrackers()

        categories.forEach { category in
            let categoryIsInSearch = emptySearch || category.label.lowercased().contains(searchText)

            let trackers = category.trackers.filter { tracker in
                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)
                let isForDate = tracker.schedule?.contains(selectedWeekday) ?? true
                let dateString = formatter.string(from: date)
                let isCompletedForDate = completedTrackers[dateString]?.contains { record in
                    record.trackerId == tracker.id
                } ?? false

                return (categoryIsInSearch || trackerIsInSearch) && isForDate && !isCompletedForDate
            }

            if !trackers.isEmpty {
                result.append((category: category, trackers: trackers))
            }
        }

        return result
    }

    // MARK: - Actions

    func markTrackerComplete(id: UUID, on date: Date) {
        let dateString = formatter.string(from: date)
        var completedTrackersForDay = completedTrackers[dateString, default: []]
        completedTrackersForDay.insert(.init(trackerId: id, date: date))

        completedTrackers[dateString] = completedTrackersForDay
    }
}
