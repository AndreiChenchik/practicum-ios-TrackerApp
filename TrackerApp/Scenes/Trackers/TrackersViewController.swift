import UIKit

final class TrackersViewController: UIViewController {
    private var searchText = "" { didSet { applySnapshot() } }
    private var selectedDate = Date() { didSet { applySnapshot() } }
    private var completedTrackers: [Date: Set<TrackerRecord>] = [:] { didSet { applySnapshot() } }
    private var categories: [TrackerCategory] = [.mockHome, .mockSmallThings, .mockSmallThings2] {
        didSet { applySnapshot() }
    }

    private lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        configureNavigationBar()

        updatePlaceholderVisibility()
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

        collection.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)

        collection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        collection.register(
            TrackerCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )

        collection.delegate = self

        collection.translatesAutoresizingMaskIntoConstraints = false

        return collection
    }()

    private lazy var placeholderView: UIView = {
        let view = UIView.placeholderView(
            message: "Что будем отслеживать?",
            icon: .trackerPlaceholder
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
        view.insertSubview(placeholderView, at: 0)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 90),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

    }

    func updatePlaceholderVisibility() {
        let trackers = categories.flatMap { $0.trackers }
        placeholderView.alpha = trackers.isEmpty ? 1 : 0
    }
}

// MARK: - Actions

private extension TrackersViewController {
    @objc func dateSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }

    @objc func addTapped() {
        present(NewTracker.startVC, animated: true)
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

                return cell
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            var id: String

            switch kind {
            case UICollectionView.elementKindSectionHeader:
                id = "header"
            default:
                id = ""
            }

            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: id,
                for: indexPath
            ) as? TrackerCategoryHeaderView else { return .init() }

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
    }

    var filteredData: FilteredData {
        guard let selectedWeekday = WeekDay(
            rawValue: Calendar.current.component(.weekday, from: selectedDate)
        ) else { preconditionFailure("Weekday must be in range of 1...7") }

        let emptySearch = searchText.isEmpty
        var result = FilteredData()

        categories.forEach { category in
            let categoryIsInSearch = emptySearch || category.label.lowercased().contains(searchText)

            let trackers = category.trackers.filter { tracker in
                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)
                let isForDate = tracker.schedule?.contains(selectedWeekday) ?? true
                let isCompletedForDate = completedTrackers[selectedDate]?.contains(
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
