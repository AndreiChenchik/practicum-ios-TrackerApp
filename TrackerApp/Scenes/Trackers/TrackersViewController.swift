import UIKit
import Combine

final class TrackersViewController: UIViewController {
    private let repo: TrackerStoring
    private let creationCoordinator: Coordinator
    private let analytics: AnalyticsService
    private lazy var dataSource = makeDataSource()

    @Published private var searchText = ""
    @Published private var selectedDate = Date()
    @Published private var selectedFilter = TrackerFilter.today

    private var cancellable: Set<AnyCancellable> = []

    init(repo: TrackerStoring, creationCoordinator: Coordinator, analytics: AnalyticsService) {
        self.repo = repo
        self.creationCoordinator = creationCoordinator
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindToUpdates() {
        repo.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.applySnapshot()
            }
            .store(in: &cancellable)

        $searchText
            .receive(on: DispatchQueue.main)
            .combineLatest($selectedDate)
            .combineLatest($selectedFilter)
            .dropFirst()
            .sink { [weak self] textDate, filter in
                guard let self else { return }
                let (text, date) = textDate
                self.applySnapshot(selectedDate: date, searchText: text, filter: filter)
            }
            .store(in: &cancellable)
    }

    // MARK: UI Components

    private lazy var filterButton: UIButton = {
        let button = YPButton(
            label: NSLocalizedString("trackers.filters",
                                     comment: "Button label for selecting filters"),
            style: .prominent
        )
        button.addTarget(self, action: #selector(openFilters), for: .touchUpInside)

        return button
    }()

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

    private lazy var datePicker: YPDatePicker = {
        let picker = YPDatePicker()

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
            collectionViewLayout: UICollectionViewCompositionalLayout.trackers
        )

        collection.keyboardDismissMode = .onDrag
        collection.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)

        collection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        collection.register(
            YPSectionHeaderCollectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(YPSectionHeaderCollectionView.self)"
        )

        collection.alwaysBounceVertical = true
        collection.delegate = self

        return collection
    }()

    private lazy var startPlaceholderView: UIView = {
        let view = UIView.placeholderView(
            message: NSLocalizedString("trackers.empty",
                                       comment: "Placeholder text when there are no trackers"),
            icon: .trackerStartPlaceholder
        )

        view.alpha = 0

        return view
    }()

    private lazy var emptyPlaceholderView: UIView = {
        let view = UIView.placeholderView(
            message: NSLocalizedString(
                "trackers.not_found",
                comment: "Placeholder text when there are no trackers found"
            ),
            icon: .trackerEmptyPlaceholder
        )

        view.alpha = 0

        return view
    }()

}

// MARK: - Lifecycle

extension TrackersViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        configureNavigationBar()

        bindToUpdates()

        collectionView.dataSource = dataSource
        applySnapshot(animatingDifferences: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.log(event: .open(scene: .main))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics.log(event: .close(scene: .main))
    }
}

// MARK: - Appearance

private extension TrackersViewController {

    func configureNavigationBar() {
        title = NSLocalizedString("trackers.title", comment: "Title of screen")

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchField
    }

    func setupAppearance() {
        view.backgroundColor = .asset(.white)
        collectionView.backgroundColor = .asset(.white)

        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(collectionView)
        view.addSubview(startPlaceholderView)
        view.addSubview(emptyPlaceholderView)
        view.addSubview(filterButton)

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            startPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func updatePlaceholderVisibility() {
        let viewIsEmpty = dataSource.numberOfSections(in: collectionView) == 0
        let haveNoTrackers = repo
            .filtered(at: nil, with: "", filteredBy: .all)
            .filter({ $0.trackers.count > 0 })
            .count == 0

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }

            self.startPlaceholderView.alpha = viewIsEmpty && haveNoTrackers ? 1 : 0
            self.emptyPlaceholderView.alpha = viewIsEmpty && !haveNoTrackers ? 1 : 0
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

        analytics.log(event: .tap(scene: .main, object: "track"))
        repo.markTrackerComplete(id: tracker.id, on: selectedDate)
    }

    @objc private func dateSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }

    @objc private func addTapped() {
        analytics.log(event: .tap(scene: .main, object: "add_track"))
        creationCoordinator.start(over: self)
    }

    @objc private func openFilters() {
        analytics.log(event: .tap(scene: .main, object: "filter"))
        let filterVC = FilterViewController(selected: selectedFilter) { [weak self] selectedFilter in
            guard let self else { return }
            self.selectedFilter = selectedFilter
        }

        let navigationController = UINavigationController()
        navigationController.configureForYPModal()

        present(navigationController, animated: true)
        navigationController.viewControllers = [filterVC]
    }

    private func edit(_ indexPath: IndexPath) {
        analytics.log(event: .tap(scene: .main, object: "edit"))

        let category = self.repo
            .filtered(at: self.selectedDate,
                      with: self.searchText,
                      filteredBy: self.selectedFilter)[indexPath.section]
        let tracker = category.trackers[indexPath.row]

        let editVC = EditViewController(
            tracker.schedule == nil ? .event : .habit,
            newTrackerRepository: .init(),
            trackerStore: repo,
            tracker: tracker,
            category: category
        )

        let navigationController = UINavigationController()
        navigationController.configureForYPModal()

        present(navigationController, animated: true)
        navigationController.viewControllers = [editVC]
    }

    private func requestDelete(_ indexPath: IndexPath) {
        analytics.log(event: .tap(scene: .main, object: "delete"))

        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("trackers.deleteRequestTitle",
                                       comment: "Tracker remove request title"),
            preferredStyle: .actionSheet
        )

        alert.addAction(.init(
            title: NSLocalizedString("trackers.doDelete",
                                     comment: "Tracker remove approval button"),
            style: .destructive, handler: { [weak self] _ in
                guard let self else { return }
                let tracker = self.repo
                    .filtered(at: self.selectedDate,
                              with: self.searchText,
                              filteredBy: self.selectedFilter)[indexPath.section]
                    .trackers[indexPath.row]

                repo.removeTracker(tracker.id)
            }
        ))

        alert.addAction(.init(
            title: NSLocalizedString("trackers.cancelDelete",
                                     comment: "Tracker remove cancel button"),
            style: .cancel
        ))

        present(alert, animated: true)
    }

    private func delete(_ indexPath: IndexPath) {

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

    private func applySnapshot(
        selectedDate: Date? = nil,
        searchText: String? = nil,
        filter: TrackerFilter? = nil,
        animatingDifferences: Bool = true
    ) {
        var snapshot = Snapshot()

        let searchText = searchText ?? self.searchText
        let selectedDate = selectedDate ?? self.selectedDate
        let filter = filter ?? self.selectedFilter

        repo.filtered(at: selectedDate, with: searchText, filteredBy: filter).forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.trackers, toSection: $0)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)

        updatePlaceholderVisibility()
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint
    ) -> UIContextMenuConfiguration? {
        configureContextMenu(path: indexPath)
    }
}

// MARK: - Context Menu
private extension TrackersViewController {
    func configureContextMenu(path: IndexPath) -> UIContextMenuConfiguration {
        let context = UIContextMenuConfiguration { [weak self] in
            guard let self else { return UIViewController() }
            let customView = self.makePreview(indexPath: path)
            return customView
        } actionProvider: { _ in
            let edit = UIAction(
                title: NSLocalizedString("trackers.edit", comment: "Tracker edit button label")
            ) { _ in
                self.edit(path)
            }

            let delete = UIAction(
                title: NSLocalizedString("trackers.delete", comment: "Tracker delete button label"),
                attributes: .destructive
            ) { _ in
                self.requestDelete(path)
            }

            return UIMenu(children: [edit, delete])
        }

        return context
    }

    func makePreview(indexPath: IndexPath) -> UIViewController {
        let tracker = self.repo
            .filtered(at: self.selectedDate,
                      with: self.searchText,
                      filteredBy: self.selectedFilter)[indexPath.section]
            .trackers[indexPath.row]

        let viewController = UIViewController()
        let preview = TrackerLabelView(frame: CGRect(x: 0, y: 0, width: 167, height: 90))
        preview.configure(with: tracker)
        viewController.view = preview
        viewController.preferredContentSize = preview.frame.size

        return viewController
    }
}
