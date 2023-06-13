import Foundation
import Combine

final class TrackerCategoryViewModel: ObservableObject, TrackerCategoryViewControllerModel {
    @Published var isDismissed = false
    @Published var selectedCategory: TrackerCategory?
    @Published var categories: [TrackerCategory] = []

    let onNewCategoryRequest: () -> Void
    let onCategorySelect: (TrackerCategory) -> Void

    private var cancellable: AnyCancellable?

    init(
        deps: Dependencies,
        selectedCategory: TrackerCategory?,
        onNewCategoryRequest: @escaping () -> Void,
        onCategorySelect: @escaping (TrackerCategory) -> Void
    ) {
        self.selectedCategory = selectedCategory
        self.onNewCategoryRequest = onNewCategoryRequest
        self.onCategorySelect = onCategorySelect

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

        onCategorySelect(category)

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
    }
}
