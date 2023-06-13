import UIKit

protocol Coordinator {
    func start(over: UIViewController)
}

final class TrackerCreationCoordinator: Coordinator {
    private var repo: TrackerStoring
    private var navigationController = UINavigationController()

    @Published private var selectedSchedule: Set<WeekDay> = []
    @Published private var selectedCategory: TrackerCategory?

    init(repo: TrackerStoring) {
        self.repo = repo
    }

    func start(over viewController: UIViewController) {
        selectedSchedule = []
        selectedCategory = nil

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
            selectedSchedule: $selectedSchedule,
            selectedCategory: $selectedCategory
        ) { [weak self] tracker, id in
            self?.repo.addTracker(tracker, toCategory: id)
        } onCategory: { [weak self] in
            self?.selectCategory()
        } onSchedule: { [weak self] in
            self?.selectSchedule()
        }

        navigationController.pushViewController(newTrackerVC, animated: true)
    }

    func selectCategory() {
        let viewModel = TrackerCategoryViewModel(
            repo.categoriesPublisher,
            selectedCategory: selectedCategory,
            addNewCategory: createCategory
        ) { [weak self] selectedCategory in
            self?.selectedCategory = selectedCategory
        }

        let categoryVC = TrackerCategoryViewController(viewModel: viewModel)

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
