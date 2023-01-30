enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday, tuesday, wednesday, thursday, friday, saturday
}

extension WeekDay {
    var label: String {
        let label: String

        switch self {
        case .sunday:
            label = "Воскресенье"
        case .monday:
            label = "Понедельник"
        case .tuesday:
            label = "Вторник"
        case .wednesday:
            label = "Среда"
        case .thursday:
            label = "Четверг"
        case .friday:
            label = "Пятница"
        case .saturday:
            label = "Суббота"
        }

        return label
    }
}

extension Set where Element == WeekDay {
    static var mockEveryDay: Set<WeekDay> {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }

    static var mockOnWeekDays: Set<WeekDay> {
        [.monday, .tuesday, .wednesday, .thursday, .friday]
    }

    static var mockOnWeekends: Set<WeekDay> {
        [.saturday, .sunday]
    }
}
