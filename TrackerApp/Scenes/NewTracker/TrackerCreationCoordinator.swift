import UIKit

protocol Coordinator {
    func start(over: UIViewController)
}

final class TrackerCreationCoordinator {
    private var deps: Dependencies
    private var navigationController = UINavigationController()

    init(deps: Dependencies) {
        self.deps = deps
    }
}

extension TrackerCreationCoordinator {
    struct Dependencies {
        let store: TrackerStoring
        let newTrackerRepo: NewTrackerRepository
    }
}

extension TrackerCreationCoordinator: Coordinator {
    func start(over viewController: UIViewController) {
        let trackerTypeVC = TrackerTypeViewController { [weak self] type in
            self?.onTypeSelect(type)
        }
        navigationController.configureForYPModal()

        viewController.present(navigationController, animated: true)
        navigationController.viewControllers = [trackerTypeVC]
    }

    func onTypeSelect(_ type: TrackerType) {
        let newTrackerVC = TrackerConfigViewController(
            type,
            newTrackerRepository: deps.newTrackerRepo,
            trackerStore: deps.store
        ) { [weak self] in
            self?.selectCategory()
        } onSchedule: { [weak self] in
            self?.selectSchedule()
        }

        navigationController.pushViewController(newTrackerVC, animated: true)
    }

    func selectCategory() {
        let viewModel = TrackerCategoryViewModel(
            deps: .init(repo: deps.store, newTrackerRepository: deps.newTrackerRepo)
        ) { [weak self] in
            self?.createCategory()
        }

        let categoryVC = TrackerCategoryViewController(viewModel: viewModel)

        navigationController.pushViewController(categoryVC, animated: true)
    }

    func selectSchedule() {
        let scheduleVC = ScheduleViewController(repo: deps.newTrackerRepo)

        navigationController.pushViewController(scheduleVC, animated: true)
    }

    func createCategory() {
        let newCategoryVC = NewCategoryViewController(store: deps.store)

        navigationController.pushViewController(newCategoryVC, animated: true)
    }
}
