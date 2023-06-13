import Foundation
import Combine

final class TrackerCategoryViewModel: ObservableObject, TrackerCategoryViewControllerModel {
    @Published var selectedCategory: TrackerCategory?
    @Published var categories: [TrackerCategory] = []

    let addNewCategory: () -> Void
    let onSelect: (TrackerCategory) -> Void

    private var cancellable: AnyCancellable?

    init(
        _ categories: some Publisher<[TrackerCategory], Never>,
        selectedCategory: TrackerCategory?,
        addNewCategory: @escaping () -> Void,
        onSelect: @escaping (TrackerCategory) -> Void
    ) {
        self.selectedCategory = selectedCategory
        self.onSelect = onSelect
        self.addNewCategory = addNewCategory

        cancellable = categories
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.categories = $0
            }
    }

    func selectCategory(_ index: Int) {
        let category = categories[index]
        selectedCategory = category
        onSelect(category)
    }

    func onNewCategory() {
        addNewCategory()
    }
}
