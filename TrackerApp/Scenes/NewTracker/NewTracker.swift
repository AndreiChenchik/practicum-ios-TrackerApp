import UIKit

enum TrackerType {
    case habit, event
}

enum NewTracker {
    static func start(
        categories: [TrackerCategory],
        onNewCategory: @escaping (TrackerCategory) -> Void,
        onNewTracker: @escaping (Tracker, TrackerCategory) -> Void
    ) -> UIViewController {
        let typeVC = TrackerTypeViewController { _ in ScheduleViewController(.mockEveryDay) { _ in } }
        let viewController = UINavigationController(rootViewController: typeVC)

        viewController.navigationBar.prefersLargeTitles = false

        viewController.navigationBar.standardAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.asset(.black),
            NSAttributedString.Key.font: UIFont.asset(.ysDisplayMedium, size: 16)
        ]

        return viewController
    }
}
