enum TrackerConfig {
    enum Section: Int, CaseIterable {
        case name, properties, emojis, colors, controls

        var label: String? {
            switch self {
            case .emojis:
                return "Emoji"
            case .colors:
                return "Цвет"
            case .name, .properties, .controls:
                return nil
            }
        }
    }

    enum Property: Int, CaseIterable {
        case category, schedule

        var label: String {
            switch self {
            case .category:
                return "Категория"
            case .schedule:
                return "Расписание"
            }
        }

        static func allCases(isIncluded: (Property) -> Bool) -> [Self] {
            Self.allCases.filter(isIncluded)
        }
    }

    enum Control: Int, CaseIterable {
        case cancel, submit

        var label: String {
            switch self {
            case .cancel:
                return "Отменить"
            case .submit:
                return "Создать"
            }
        }
    }

    enum Emoji {
        static let list = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
            "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
        ]
    }
}
