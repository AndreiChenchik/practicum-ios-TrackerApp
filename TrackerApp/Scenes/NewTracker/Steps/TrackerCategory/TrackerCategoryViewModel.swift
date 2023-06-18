import Foundation
import Combine

final class TrackerCategoryViewModel: ObservableObject, TrackerCategoryViewControllerModel {
    let deps: Dependencies

    @Published var isDismissed = false
    @Published var selectedCategory: TrackerCategory?
    @Published var categories: [TrackerCategory] = []

    let onNewCategoryRequest: () -> Void

    private var cancellable: AnyCancellable?

    init(
        deps: Dependencies,
        onNewCategoryRequest: @escaping () -> Void
    ) {
        self.deps = deps
        self.selectedCategory = deps.newTrackerRepository.selectedCategory
        self.onNewCategoryRequest = onNewCategoryRequest

        cancellable = deps.repo
            .categoriesPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.categories = $0
            }
    }

    func selectCategory(_ index: Int) {
        let category = categories[index]

        deps.newTrackerRepository.selectedCategory = category

        selectedCategory = category
        isDismissed = true
    }

    func onNewCategory() {
        onNewCategoryRequest()
    }
}

extension TrackerCategoryViewModel {
    struct Dependencies {
        var repo: TrackerStoring
        var newTrackerRepository: NewTrackerRepository
    }
}
