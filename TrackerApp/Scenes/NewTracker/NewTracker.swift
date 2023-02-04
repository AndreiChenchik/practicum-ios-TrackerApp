import UIKit

enum NewTracker {
    static func start(
        categories: [TrackerCategory],
        onNewCategory: @escaping (TrackerCategory) -> Void,
        onNewTracker: @escaping (Tracker, TrackerCategory) -> Void
    ) -> UIViewController {
        let typeVC = TrackerTypeViewController { type in
            TrackerConfigViewController(type, categories: categories, onCreate: onNewTracker)
        }

        let viewController = UINavigationController(rootViewController: typeVC)

        viewController.configureForModal()

        return viewController
    }
}

extension UINavigationController {
    func configureForModal() {
        navigationBar.prefersLargeTitles = false

        navigationBar.standardAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.asset(.black),
            NSAttributedString.Key.font: UIFont.asset(.ysDisplayMedium, size: 16)
        ]
    }
}
