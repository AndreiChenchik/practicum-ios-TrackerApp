import Foundation
import Combine
import CoreData
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
    let context: NSManagedObjectContext

    @Published var completedTrackers: [String: Set<TrackerRecord>] = [:]
    @Published var categories: [TrackerCategory] = [.mockHome, .mockSmallThings, .mockSmallThings2]

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private lazy var trackersController: NSFetchedResultsController<TrackerCD> = {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    private lazy var categoryController: NSFetchedResultsController<TrackerCategoryCD> = {
        let fetchRequest = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    private lazy var recordController: NSFetchedResultsController<TrackerRecordCD> = {
        let fetchRequest = TrackerRecordCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(context: NSManagedObjectContext? = nil) {
        if let context {
            self.context = context
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                preconditionFailure("Something went terribly wrong")
            }

            self.context = appDelegate.persistentContainer.viewContext
        }

        super.init()
        fetchCoreData()
        _ = trackersController.fetchedObjects
    }

    func fetchCoreData() {
        let categoriesCD = categoryController.fetchedObjects ?? []
        categories = categoriesCD.compactMap { .fromCoreData($0) }
        let recordsCD = recordController.fetchedObjects ?? []
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
        let categoryCD = TrackerCategoryCD(context: context)
        categoryCD.id = category.id
        categoryCD.label = category.label
        categoryCD.createdAt = Date()

        try? context.save()
    }

    func addTracker(_ tracker: Tracker, toCategory id: UUID) {
        let request = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.fetchLimit = 1
        guard let categoryCD = try? context.fetch(request) else { return }

        let trackerCD = TrackerCD(context: context)
        trackerCD.createdAt = Date()
        trackerCD.id = tracker.id
        trackerCD.emoji = tracker.emoji
        trackerCD.label = tracker.label
        trackerCD.colorHex = tracker.color.uiColor.hexString
        trackerCD.category = categoryCD.first

        if let schedule = tracker.schedule {
            trackerCD.schedule = try? JSONEncoder().encode(schedule)
        }

        do {
            try context.save()
        } catch {
            context.rollback()
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

            let trackers = category.trackers.filter { tracker in
                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)

                var isForDate = true
                if let selectedWeekday {
                    isForDate = tracker.schedule?.contains(selectedWeekday) ?? true

                }

                var isCompletedForDate = false
                if let dateString {
                    isCompletedForDate = completedTrackers[dateString]?.contains { record in
                        record.trackerId == tracker.id
                    } ?? false
                }

                return (categoryIsInSearch || trackerIsInSearch) && isForDate && !isCompletedForDate
            }

            if !trackers.isEmpty {
                result.append(.init(id: category.id, label: category.label, trackers: trackers))
            }
        }

        return result
    }

    // MARK: - Actions

    func markTrackerComplete(id: UUID, on date: Date) {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.fetchLimit = 1
        guard let trackerCD = try? context.fetch(request) else { return }

        let recordCD = TrackerRecordCD(context: context)
        recordCD.date = date
        recordCD.tracker = trackerCD.first

        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRepository: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        fetchCoreData()
    }
}
