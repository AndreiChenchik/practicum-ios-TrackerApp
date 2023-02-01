import Foundation

struct TrackerCategory: Identifiable, Hashable {
    let id: UUID
    let label: String
    let trackers: [Tracker]

    init(id: UUID = UUID(), label: String, trackers: [Tracker]) {
        self.id = id
        self.label = label
        self.trackers = trackers
    }
}

extension TrackerCategory {
    static var mockHome: Self {
        .init(label: "Домашний уют", trackers: [.mockPlants])
    }

    static var mockSmallThings: Self {
        .init(label: "Радостные мелочи", trackers: [.mockCatCamera, .mockGrandma, .mockDating])
    }

    static var mockSmallThings2: Self {
        .init(label: "Радостные мелочи 2", trackers: [.mockCatCamera, .mockGrandma, .mockDating])
    }
}
