enum WeekDay {
    case monday, tuesday, wednesday, thursday, friday
    case saturday, sunday
}

extension Set where Element == WeekDay {
    static var everyDay: Set<WeekDay> {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }

    static var onWeekDays: Set<WeekDay> {
        [.monday, .tuesday, .wednesday, .thursday, .friday]
    }

    static var onWeekends: Set<WeekDay> {
        [.saturday, .sunday]
    }
}
