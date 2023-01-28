struct TrackerCategory {
    let label: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    static var mocks: [Self] {
        [
            .init(label: "Домашний уют", trackers: [
                .init(label: "Поливая растения",
                      emoji: "❤️",
                      color: .init(hex: "#33CF69"),
                      schedule: [])
            ]),
            .init(label: "Радостные мелочи", trackers: [
                .init(label: "Кошка заслонила камеру на созвоне",
                      emoji: "😻",
                      color: .init(hex: "#FF881E"),
                      schedule: []),
                .init(label: "Бабушка прислала открытку в вотсапе",
                      emoji: "🌺",
                      color: .init(hex: "#FD4C49"),
                      schedule: []),
                .init(label: "Свидания в апреле",
                      emoji: "❤️",
                      color: .init(hex: "#7994F5"),
                      schedule: [])
            ]),
        ]
    }
}
