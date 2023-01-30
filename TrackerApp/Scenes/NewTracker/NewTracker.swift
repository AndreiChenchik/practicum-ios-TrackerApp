import UIKit

enum NewTracker {
    static func start(
        categories: [TrackerCategory],
        onNewCategory: @escaping (TrackerCategory) -> Void,
        onNewTracker: @escaping (Tracker, TrackerCategory) -> Void
    ) -> UIViewController {
        let typeVC = TrackerTypeViewController { type in
            NewTrackerViewController(type, categories: categories, onCreate: onNewTracker)
        }

        let viewController = UINavigationController(rootViewController: typeVC)

        viewController.navigationBar.prefersLargeTitles = false

        viewController.navigationBar.standardAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.asset(.black),
            NSAttributedString.Key.font: UIFont.asset(.ysDisplayMedium, size: 16)
        ]

        return viewController
    }
}
