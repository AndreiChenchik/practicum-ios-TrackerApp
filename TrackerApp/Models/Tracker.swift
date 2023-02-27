import Foundation

struct Tracker: Identifiable, Hashable {
    var id = UUID()
    let label: String
    let emoji: String
    let color: TrackerColor
    let schedule: Set<WeekDay>?
}

extension Tracker {
    static var mockCatCamera: Self {
        .init(label: "Кошка заслонила камеру на созвоне", emoji: "😻", color: .lightOrange, schedule: nil)
    }

    static var mockGrandma: Self {
        .init(label: "Бабушка прислала открытку в вотсапе", emoji: "🌺", color: .red, schedule: nil)
    }

    static var mockDating: Self {
        .init(label: "Свидания в апреле", emoji: "❤️", color: .paleBlue, schedule: .mockOnWeekends)
    }

    static var mockPlants: Self {
        .init(label: "Поливая растения", emoji: "❤️", color: .green, schedule: .mockEveryDay)
    }
}

extension Tracker {
    static func fromCoreData(_ data: TrackerCD, decoder: JSONDecoder) -> Tracker? {
        guard
            let id = data.id,
            let label = data.label,
            let emoji = data.emoji,
            let hex = data.colorHex,
            let color = TrackerColor(rawValue: hex)
        else { return nil }

        var schedule: Set<WeekDay>?
        if let scheduleData = data.schedule {
            schedule = try? decoder.decode(Set<WeekDay>.self, from: scheduleData)
        }

        return .init(id: id, label: label, emoji: emoji, color: color, schedule: schedule)
    }
}
