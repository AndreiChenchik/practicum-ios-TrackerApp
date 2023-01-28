import UIKit

final class TrackersViewController: UIViewController {

    private var items: [Int] = [] {
        didSet { updatePlaceholderVisibility() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        configureNavigationBar()

        updatePlaceholderVisibility()
    }

    // MARK: Components

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

        collection.dataSource = self
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

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 90),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

    }

    func updatePlaceholderVisibility() {
        placeholderView.alpha = items.isEmpty ? 1 : 0
    }
}

// MARK: - Actions

private extension TrackersViewController {
    @objc func dateSelected(_ sender: UIDatePicker) {
        print(sender.date)
    }

    @objc func addTapped() {
        print("tapped")
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        fatalError()
    }

}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {

}
