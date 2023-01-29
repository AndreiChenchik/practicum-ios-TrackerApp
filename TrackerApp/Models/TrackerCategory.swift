struct TrackerCategory: Hashable {
    let label: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    static var mocks: [Self] {
        [.init(label: "Домашний уют", trackers: [
            .init(label: "Поливая растения", emoji: "❤️", color: .green, schedule: .everyDay)]),
         .init(label: "Радостные мелочи", trackers: [
            .init(label: "Кошка заслонила камеру на созвоне", emoji: "😻", color: .lightOrange, schedule: nil),
            .init(label: "Бабушка прислала открытку в вотсапе", emoji: "🌺", color: .red, schedule: nil),
            .init(label: "Свидания в апреле", emoji: "❤️", color: .paleBlue, schedule: .onWeekends)]),
         .init(label: "Радостные мелочи 2", trackers: [
            .init(label: "Кошка заслонила камеру на созвоне", emoji: "😻", color: .lightOrange, schedule: nil),
            .init(label: "Бабушка прислала открытку в вотсапе", emoji: "🌺", color: .red, schedule: nil),
            .init(label: "Свидания в апреле", emoji: "❤️", color: .paleBlue, schedule: .onWeekends)])
        ]
    }
}
