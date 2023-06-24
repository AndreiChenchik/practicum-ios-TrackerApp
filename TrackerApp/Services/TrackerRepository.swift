import Foundation
import Combine
import UIKit

protocol TrackerStoring {
    func addCategory(_ category: TrackerCategory)
    func addTracker(_ tracker: Tracker, toCategory id: UUID)
    func markTrackerComplete(id: UUID, on date: Date)

    func filtered(at date: Date?, with searchText: String) -> [TrackerCategory]

    var categoriesPublisher: Published<[TrackerCategory]>.Publisher { get }
    var objectWillChange: ObservableObjectPublisher { get }
}

final class TrackerRepository: NSObject, ObservableObject {
    @Published var completedTrackers: [String: Set<TrackerRecord>] = [:]
    @Published var categories: [TrackerCategory] = [.mockHome, .mockSmallThings, .mockSmallThings2]

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()

    private lazy var trackerStore: TrackerStore = { .init(delegate: self) }()
    private lazy var categoryStore: TrackerCategoryStore = { .init(delegate: self) }()
    private lazy var recordStore: TrackerRecordStore = { .init(delegate: self) }()

    override init() {
        super.init()
        fetchData()
    }

    func fetchData() {
        let categoriesCD = categoryStore.data
        categories = categoriesCD.compactMap { TrackerCategory.fromCoreData($0,
                                                                            decoder: jsonDecoder) }
        let recordsCD = recordStore.data
        let records = recordsCD.compactMap { TrackerRecord.fromCoreData($0) }
        completedTrackers = records.reduce(into: [:]) { result, record in
            let dateString = formatter.string(from: record.date)

            var trackers = result[dateString, default: []]
            trackers.insert(record)

            result[dateString] = trackers
        }
    }
}

extension TrackerRepository: TrackerStoring {
    var categoriesPublisher: Published<[TrackerCategory]>.Publisher { $categories }

    // MARK: - Creation

    func addCategory(_ category: TrackerCategory) {
        categoryStore.create { categoryCD in
            categoryCD.id = category.id
            categoryCD.label = category.label
        }
    }

    func addTracker(_ tracker: Tracker, toCategory id: UUID) {
        guard let categoryCD = categoryStore.getById(id) else { return }

        trackerStore.create { trackerCD in
            trackerCD.createdAt = Date()
            trackerCD.id = tracker.id
            trackerCD.emoji = tracker.emoji
            trackerCD.label = tracker.label
            trackerCD.colorHex = tracker.color.uiColor.hexString
            trackerCD.category = categoryCD

            if let schedule = tracker.schedule {
                trackerCD.schedule = try? jsonEncoder.encode(schedule)
            }
        }
    }

    // MARK: - Data

    func filtered(at date: Date?, with searchText: String) -> [TrackerCategory] {
        let selectedWeekday: WeekDay?
        let dateString: String?
        if let date {
            selectedWeekday = WeekDay(rawValue: Calendar.current.component(.weekday, from: date))
            dateString = formatter.string(from: date)
        } else {
            selectedWeekday = nil
            dateString = nil
        }

        let emptySearch = searchText.isEmpty
        var result = [TrackerCategory]()

        categories.forEach { category in
            let categoryIsInSearch = emptySearch || category.label.lowercased().contains(searchText)

            var trackers = category.trackers.filter { tracker in
                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)

                var isForDate = true
                if let selectedWeekday {
                    isForDate = tracker.schedule?.contains(selectedWeekday) ?? true
                }

                return (categoryIsInSearch || trackerIsInSearch) && isForDate
            }

            trackers = trackers.map { tracker in
                var isCompletedForDate = false
                if let dateString {
                    isCompletedForDate = completedTrackers[dateString]?.contains { record in
                        record.trackerId == tracker.id
                    } ?? false
                }

                return .init(id: tracker.id,
                             label: tracker.label,
                             emoji: tracker.emoji,
                             color: tracker.color,
                             schedule: tracker.schedule,
                             completedCount: tracker.completedCount,
                             isCompleted: isCompletedForDate)
            }

            trackers.sort { $0.label > $1.label }

            if !trackers.isEmpty {
                result.append(.init(id: category.id, label: category.label, trackers: trackers))
            }
        }

        return result
    }

    // MARK: - Actions

    func markTrackerComplete(id: UUID, on date: Date) {
        guard let trackerCD = trackerStore.getById(id) else { return }

        recordStore.create { recordCD in
            recordCD.date = date
            recordCD.tracker = trackerCD
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRepository: StoreDelegate {
    func didChangeContent() {
        fetchData()
    }
}
