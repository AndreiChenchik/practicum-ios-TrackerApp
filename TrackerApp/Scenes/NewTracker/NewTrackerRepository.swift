import Foundation

final class NewTrackerRepository: ObservableObject {
    @Published var selectedSchedule: Set<WeekDay> = []
    @Published var selectedCategory: TrackerCategory?
}
