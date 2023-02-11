import UIKit
import Combine

final class TrackersViewController: UIViewController {
    private var searchText = "" { didSet { applySnapshot() } }
    private var selectedDate = Date() { didSet { applySnapshot() } }

    private var repo: TrackerStoring
    private var cancellable: Set<AnyCancellable> = []

    init(repo: TrackerStoring) {
        self.repo = repo
        super.init(nibName: nil, bundle: nil)

        repo.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.applySnapshot()
            }
            .store(in: &cancellable)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var dataSource = makeDataSource()
    private var kvObservers: Set<NSKeyValueObservation> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        configureNavigationBar()

        collectionView.dataSource = dataSource
        applySnapshot(animatingDifferences: false)
    }

    // MARK: UI Components

    private lazy var addButton: UIBarButtonItem = {
        let addIcon = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )

        let addButton = UIBarButtonItem(
            image: addIcon,
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )

        addButton.tintColor = .asset(.black)

        return addButton
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact

        picker.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)

        picker.translatesAutoresizingMaskIntoConstraints = false

        return picker
    }()

    private lazy var searchField: UISearchController = {
        let search = UISearchController()

        search.delegate = self
        search.searchBar.delegate = self

        return search
    }()

    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )

        collection.keyboardDismissMode = .onDrag
        collection.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)

        collection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        collection.register(
            YPSectionHeaderCollectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(YPSectionHeaderCollectionView.self)"
        )

        collection.delegate = self

        collection.translatesAutoresizingMaskIntoConstraints = false

        return collection
    }()

    private lazy var startPlaceholderView: UIView = {
        let view = UIView.placeholderView(
            message: "Что будем отслеживать?",
            icon: .trackerStartPlaceholder
        )

        view.alpha = 0

        return view
    }()

    private lazy var emptyPlaceholderView: UIView = {
        let view = UIView.placeholderView(
            message: "Ничего не найдено",
            icon: .trackerEmptyPlaceholder
        )

        view.alpha = 0

        return view
    }()

}

// MARK: - Appearance

private extension TrackersViewController {

    func configureNavigationBar() {
        title = "Трекеры"

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchField
    }

    func setupAppearance() {
        view.backgroundColor = .asset(.white)

        view.addSubview(collectionView)
        view.addSubview(startPlaceholderView)
        view.addSubview(emptyPlaceholderView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            startPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        changeDatePickerStyle()
    }

    func updatePlaceholderVisibility() {
        let viewIsEmpty = dataSource.numberOfSections(in: collectionView) == 0
        let haveNoTrackers = repo.categories.filter({ $0.trackers.count > 0 }).count == 0

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }

            self.startPlaceholderView.alpha = viewIsEmpty && haveNoTrackers ? 1 : 0
            self.emptyPlaceholderView.alpha = viewIsEmpty && !haveNoTrackers ? 1 : 0
        }
    }

    func changeDatePickerStyle() {
        datePicker
            .subViewsWhere { view in
                guard let backgroundColor = view.backgroundColor else { return false }
                return backgroundColor.cgColor.alpha != 1
            }
            .forEach { view in
                view.backgroundColor = .asset(.blue)

                kvObservers.insert(
                    view.observe(\.backgroundColor) { [weak view] _, _ in
                        guard let view, let backgroundColor = view.backgroundColor else { return }

                        if backgroundColor != .asset(.blue) {
                            view.backgroundColor = .asset(.blue)
                        }
                    }
                )
            }

        datePicker
            .subViewsWhere { view in
                view is UILabel
            }
            .forEach { view in
                guard let label = view as? UILabel else { return }
                label.tintColor = .asset(.white)
                label.textColor = .asset(.white)
                label.font = .asset(.ysDisplayRegular, size: 17)

                kvObservers.insert(
                    label.observe(\.textColor) { [weak label] _, _ in
                        guard let label, let textColor = label.textColor else { return }

                        if textColor != .asset(.white) {
                            label.textColor = .asset(.white)
                        }
                    }
                )
            }
    }
}

// MARK: - Actions

extension TrackersViewController {
    func trackerMarkedCompleted(_ cell: TrackerCollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let tracker = dataSource.itemIdentifier(for: indexPath)
        else {
            assertionFailure("Can't find cell")
            return
        }

        var completedTrackersForDay = repo.completedTrackers[selectedDate, default: []]
        completedTrackersForDay.insert(.init(trackerId: tracker.id, date: selectedDate))

        repo.completedTrackers[selectedDate] = completedTrackersForDay
    }

    @objc private func dateSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }

    @objc private func addTapped() {
        let newTrackerVC = NewTracker.start(
            categories: repo.categories,
            onNewCategory: addCategory,
            onNewTracker: addTracker
        )

        present(newTrackerVC, animated: true)
    }

    func addCategory(_ category: TrackerCategory) {
        var newCategories = repo.categories
        newCategories.append(category)
        repo.categories = newCategories
    }

    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        var newCategories = repo.categories

        guard let index = newCategories.firstIndex(where: { $0.id == category.id }) else {
            assertionFailure("Data not in sync")
            return
        }

        let existingCategory = newCategories[index]
        var trackers = existingCategory.trackers
        trackers.append(tracker)

        let newCategory = TrackerCategory(label: existingCategory.label, trackers: trackers)
        newCategories[index] = newCategory

        repo.categories = newCategories
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText.lowercased()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.dataSource.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )

        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9 - 32) / 2, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 16, bottom: 16, right: 16)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9
    }
}

// MARK: - UICollectionViewDiffableDataSource

private extension TrackersViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<TrackerCategory, Tracker>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, tracker) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath
                ) as? TrackerCollectionViewCell

                cell?.configure(with: tracker)
                cell?.delegate = self

                return cell
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            var id: String

            switch kind {
            case UICollectionView.elementKindSectionHeader:
                id = "\(YPSectionHeaderCollectionView.self)"
            default:
                id = ""
            }

            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: id,
                for: indexPath
            ) as? YPSectionHeaderCollectionView else { return .init() }

            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            view.configure(label: section.label)

            return view
        }

        return dataSource
    }
}

// MARK: - Data filtering

private extension TrackersViewController {
    typealias FilteredData = [(category: TrackerCategory, trackers: [Tracker])]

    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()

        filteredData.forEach {
            snapshot.appendSections([$0.category])
            snapshot.appendItems($0.trackers, toSection: $0.category)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)

        updatePlaceholderVisibility()
    }

    var filteredData: FilteredData {
        guard let selectedWeekday = WeekDay(
            rawValue: Calendar.current.component(.weekday, from: selectedDate)
        ) else { preconditionFailure("Weekday must be in range of 1...7") }

        let emptySearch = searchText.isEmpty
        var result = FilteredData()

        repo.categories.forEach { category in
            let categoryIsInSearch = emptySearch || category.label.lowercased().contains(searchText)

            let trackers = category.trackers.filter { tracker in
                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)
                let isForDate = tracker.schedule?.contains(selectedWeekday) ?? true
                let isCompletedForDate = repo.completedTrackers[selectedDate]?.contains(
                    .init(trackerId: tracker.id, date: selectedDate)
                ) ?? false

                return (categoryIsInSearch || trackerIsInSearch) && isForDate && !isCompletedForDate
            }

            if !trackers.isEmpty {
                result.append((category: category, trackers: trackers))
            }
        }

        return result
    }
}
