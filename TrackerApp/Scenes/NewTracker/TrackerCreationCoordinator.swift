import UIKit

protocol Coordinator {
    func start(over: UIViewController)
}

final class TrackerCreationCoordinator: Coordinator {
    private var repo: TrackerStoring
    private lazy var navigationController = UINavigationController()

    init(repo: TrackerStoring) {
        self.repo = repo
    }

    func start(over viewController: UIViewController) {
        let trackerTypeVC = TrackerTypeViewController(completion: onTypeSelect)
        navigationController.configureForYPModal()

        viewController.present(navigationController, animated: true)
        navigationController.pushViewController(trackerTypeVC, animated: false)
    }

    func onTypeSelect(_ type: TrackerType) {
        let newTrackerVC = TrackerConfigViewController(
            type,
            categories: repo.categories,
            onCreate: repo.addTracker,
            onNewCategory: repo.addCategory
        )

        navigationController.pushViewController(newTrackerVC, animated: true)
    }
}
