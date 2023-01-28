import UIKit

enum NewTracker {
    static var startVC: UIViewController {
        let habitVC = OnboardingViewController()
        let eventVC = OnboardingViewController()

        let typeVC = TrackerTypeViewController(habitVC: habitVC, eventVC: eventVC)

        let viewController = UINavigationController(rootViewController: typeVC)

        viewController.navigationBar.prefersLargeTitles = false

        viewController.navigationBar.standardAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.asset(.black),
            NSAttributedString.Key.font: UIFont.asset(.ysDisplayMedium, size: 16)
        ]

        return viewController
    }
}
