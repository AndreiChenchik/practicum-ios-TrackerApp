import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case sunday = 1
    case monday, tuesday, wednesday, thursday, friday, saturday
}

extension WeekDay {
    var label: String {
        Calendar.current.weekdaySymbols[self.rawValue-1]
    }

    var shortLabel: String {
        Calendar.current.shortWeekdaySymbols[self.rawValue-1]
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

    var shortDescription: String? {
        guard self != Set(WeekDay.allCases) else {
            return NSLocalizedString("weekday.all_days.short",
                                     comment: "Short description of full week schedule")
        }

        let listOfDayLabels = Calendar.current.shortWeekdaySymbols

        let scheduleDescription = WeekDay.allCasesSortedForUserCalendar
            .filter { self.contains($0) }
            .map { listOfDayLabels[$0.rawValue-1] }
            .joined(separator: ", ")
        return scheduleDescription.isEmpty ? nil : scheduleDescription
    }
}
