import Foundation
import Combine

final class TrackerCategoryViewModel {
    let onNewCategory: () -> Void
    let onSelect: (TrackerCategory) -> Void

    var categories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory?

    private var cancellable: Set<AnyCancellable> = []

    private var onUpdate: () -> Void = {}

    init(
        _ categories: some Publisher<[TrackerCategory], Never>,
        selectedCategory: TrackerCategory?,
        onNewCategory: @escaping () -> Void,
        onSelect: @escaping (TrackerCategory) -> Void
    ) {
        self.selectedCategory = selectedCategory
        self.onSelect = onSelect
        self.onNewCategory = onNewCategory

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

    func selectCategory(_ indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategory = category
        onSelect(category)
    }
}
