import UIKit

protocol Coordinator {
    func start(over: UIViewController)
}

final class TrackerCreationCoordinator: Coordinator {
    private var repo: TrackerStoring // ViewModel
    private lazy var navigationController = UINavigationController()

    @Published private var selectedSchedule: Set<WeekDay> = []
    @Published private var selectedCategory: TrackerCategory?

    init(repo: TrackerStoring) {
        self.repo = repo
    }

    func start(over viewController: UIViewController) {
        selectedSchedule = []
        selectedCategory = nil

        let trackerTypeVC = TrackerTypeViewController(completion: onTypeSelect)
        navigationController.configureForYPModal()

        viewController.present(navigationController, animated: true)
        navigationController.pushViewController(trackerTypeVC, animated: false)
    }

    func onTypeSelect(_ type: TrackerType) {
        let newTrackerVC = TrackerConfigViewController(
            type,
            selectedSchedule: $selectedSchedule,
            selectedCategory: $selectedCategory,
            onCreate: repo.addTracker,
            onCategory: selectCategory,
            onSchedule: selectSchedule
        )

        navigationController.pushViewController(newTrackerVC, animated: true)
    }

    func selectCategory() {
        let categoryVC = TrackerCategoryViewController(
            repo.categoriesPublisher,
            selectedCategory: selectedCategory,
            onNewCategory: createCategory
        ) { [weak self] selectedCategory in
            self?.selectedCategory = selectedCategory
        }

        navigationController.pushViewController(categoryVC, animated: true)
    }

    func selectSchedule() {
        let scheduleVC = ScheduleViewController(selectedSchedule) { [weak self] newSchedule in
            self?.selectedSchedule = newSchedule
        }

        navigationController.pushViewController(scheduleVC, animated: true)
    }

    func createCategory() {
        let newCategoryVC = NewCategoryViewController { [weak self] newCategory in
            self?.repo.addCategory(newCategory)
        }

        navigationController.pushViewController(newCategoryVC, animated: true)
    }
}
