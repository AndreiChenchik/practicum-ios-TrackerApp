import Foundation

enum TrackerConfig {
    enum Section: Int, CaseIterable {
        case name, properties, emojis, colors, controls

        var label: String? {
            switch self {
            case .emojis:
                return NSLocalizedString("newTracker.config.emojiSectionTitle",
                                         comment: "Section title")
            case .colors:
                return NSLocalizedString("newTracker.config.colorSectionTitle",
                                         comment: "Section title")
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
                return NSLocalizedString("newTracker.config.categoryLinkText",
                                         comment: "Link text")
            case .schedule:
                return NSLocalizedString("newTracker.config.scheduleLinkText",
                                         comment: "Link text")
            }
        }

        static func allCases(isIncluded: (Property) -> Bool) -> [Self] {
            Self.allCases.filter(isIncluded)
        }
    }

    enum Control: Int, CaseIterable {
        case cancel, submit
    }

    enum Emoji {
        static let list = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
            "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
        ]
    }
}
