import Foundation

struct Tracker: Identifiable, Hashable {
    var id = UUID()
    var label: String
    var emoji: String
    var color: TrackerColor
    var schedule: Set<WeekDay>?
    var completedCount: Int
    var isCompleted: Bool
    var isPinned: Bool
    var categoryId: UUID
}

extension Tracker {
    static var mockCatCamera: Self {
        .init(label: "Кошка заслонила камеру на созвоне",
              emoji: "😻",
              color: .lightOrange,
              schedule: nil,
              completedCount: 10,
              isCompleted: false,
              isPinned: false,
              categoryId: .init())
    }

    static var mockGrandma: Self {
        .init(label: "Бабушка прислала открытку в вотсапе",
              emoji: "🌺",
              color: .red,
              schedule: nil,
              completedCount: 125,
              isCompleted: false,
              isPinned: false,
              categoryId: .init())
    }

    static var mockDating: Self {
        .init(label: "Свидания в апреле",
              emoji: "❤️",
              color: .paleBlue,
              schedule: .mockOnWeekends,
              completedCount: 0,
              isCompleted: false,
              isPinned: true,
              categoryId: .init())
    }

    static var mockPlants: Self {
        .init(label: "Поливая растения",
              emoji: "❤️",
              color: .green,
              schedule: .mockEveryDay,
              completedCount: 120,
              isCompleted: false,
              isPinned: true,
              categoryId: .init())
    }
}

extension Tracker {
    static func fromCoreData(_ data: TrackerCD, decoder: JSONDecoder) -> Tracker? {
        guard
            let id = data.id,
            let label = data.label,
            let emoji = data.emoji,
            let hex = data.colorHex,
            let completedCount = data.records?.count,
            let color = TrackerColor(rawValue: hex),
            let categoryId = data.category?.id
        else { return nil }

        var schedule: Set<WeekDay>?
        if let scheduleData = data.schedule {
            schedule = try? decoder.decode(Set<WeekDay>.self, from: scheduleData)
        }

        return .init(id: id,
                     label: label,
                     emoji: emoji,
                     color: color,
                     schedule: schedule,
                     completedCount: completedCount,
                     isCompleted: false,
                     isPinned: data.isPinned,
                     categoryId: categoryId)
    }
}
