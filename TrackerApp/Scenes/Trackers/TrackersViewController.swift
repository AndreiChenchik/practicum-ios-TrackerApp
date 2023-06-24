import UIKit
import Combine

final class TrackersViewController: UIViewController {
    private let repo: TrackerStoring
    private let creationCoordinator: Coordinator
    private let analytics: AnalyticsService
    private lazy var dataSource = makeDataSource()

    @Published private var searchText = ""
    @Published private var selectedDate = Date()

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
            .dropFirst()
            .sink { [weak self] text, date in
                guard let self else { return }
                self.applySnapshot(selectedDate: date, searchText: text)
            }
            .store(in: &cancellable)
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

        view.addSubview(collectionView)
        view.addSubview(startPlaceholderView)
        view.addSubview(emptyPlaceholderView)

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            startPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func updatePlaceholderVisibility() {
        let viewIsEmpty = dataSource.numberOfSections(in: collectionView) == 0
        let haveNoTrackers = repo
            .filtered(at: nil, with: "")
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
        animatingDifferences: Bool = true
    ) {
        var snapshot = Snapshot()

        let searchText = searchText ?? self.searchText
        let selectedDate = selectedDate ?? self.selectedDate

        repo.filtered(at: selectedDate, with: searchText).forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.trackers, toSection: $0)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)

        updatePlaceholderVisibility()
    }
}
