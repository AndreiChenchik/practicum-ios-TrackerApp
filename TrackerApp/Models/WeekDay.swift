enum WeekDay {
    case monday, tuesday, wednesday, thursday, friday
    case saturday, sunday
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
