import Foundation

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

    var shortLabel: String {
        let label: String

        switch self {
        case .sunday:
            label = "Вс"
        case .monday:
            label = "Пн"
        case .tuesday:
            label = "Вт"
        case .wednesday:
            label = "Ср"
        case .thursday:
            label = "Чт"
        case .friday:
            label = "Пт"
        case .saturday:
            label = "Сб"
        }

        return label
    }
}

extension WeekDay {
    static var allCasesSortedForUserCalendar: [WeekDay] {
        guard
            let usersFirstDay = WeekDay(rawValue: Calendar.current.firstWeekday),
            let sortedDays = WeekDay.allCases.startingFrom(usersFirstDay)
        else { return WeekDay.allCases }

        return sortedDays
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
