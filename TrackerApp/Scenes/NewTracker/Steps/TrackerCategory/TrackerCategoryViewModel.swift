import Foundation
import Combine

final class TrackerCategoryViewModel: TrackerCategoryViewControllerModel {
    var selectedCategory: TrackerCategory?
    var categories: [TrackerCategory] = []

    let addNewCategory: () -> Void
    let onSelect: (TrackerCategory) -> Void

    private var cancellable: Set<AnyCancellable> = []
    private var onUpdate: () -> Void = {}

    init(
        _ categories: some Publisher<[TrackerCategory], Never>,
        selectedCategory: TrackerCategory?,
        addNewCategory: @escaping () -> Void,
        onSelect: @escaping (TrackerCategory) -> Void
    ) {
        self.selectedCategory = selectedCategory
        self.onSelect = onSelect
        self.addNewCategory = addNewCategory

        categories
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.categories = $0
                self?.onUpdate()
            }
            .store(in: &cancellable)
    }

    func bind(_ onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
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
