import UIKit
import Combine

final class EditViewController: UIViewController {
    typealias Property = TrackerConfig.Property
    typealias Emoji = TrackerConfig.Emoji
    typealias Control = TrackerConfig.Control
    typealias Section = TrackerConfig.Section

    private let type: TrackerType
    private let trackerStore: TrackerStoring
    private let newTrackerRepository: NewTrackerRepository

    private var tracker: Tracker
    private var schedule: Set<WeekDay> = [] { didSet { updateButtonStatus() } }
    private var trackerName: String? { didSet { updateButtonStatus() } }
    private var selectedCategory: TrackerCategory? { didSet { updateButtonStatus() } }
    private var selectedEmoji: String? { didSet { updateButtonStatus() } }
    private var selectedColor: TrackerColor? { didSet { updateButtonStatus() } }
    private var numberOfDays: Int

    private var relevantProperties: [Property] {
        Property.allCases { $0 != .schedule || type == .habit }
    }

    private var cancellable: Set<AnyCancellable> = []

    init(
        _ type: TrackerType,
        newTrackerRepository: NewTrackerRepository,
        trackerStore: TrackerStoring,
        tracker: Tracker,
        category: TrackerCategory
    ) {
        self.type = type
        self.trackerStore = trackerStore
        self.numberOfDays = tracker.completedCount
        self.tracker = tracker
        self.newTrackerRepository = newTrackerRepository

        super.init(nibName: nil, bundle: nil)

        newTrackerRepository.$selectedSchedule
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.schedule = $0
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)

        newTrackerRepository.$selectedCategory
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.selectedCategory = $0
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)

        newTrackerRepository.selectedCategory = category
        newTrackerRepository.selectedSchedule = tracker.schedule ?? []
        trackerName = tracker.label
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .asset(.white)

        title = NSLocalizedString("trackers.edit.title", comment: "Edit screen title")
        navigationItem.hidesBackButton = true

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout.trackerEdit
        )

        collection.keyboardDismissMode = .onDrag

        collection.register(YPInputCollectionCell.self,
                            forCellWithReuseIdentifier: "\(YPInputCollectionCell.self)")
        collection.register(YPLinkCollectionCell.self,
                            forCellWithReuseIdentifier: "\(YPLinkCollectionCell.self)")
        collection.register(TrackerEmojiCollectionCell.self,
                            forCellWithReuseIdentifier: "\(TrackerEmojiCollectionCell.self)")
        collection.register(TrackerColorCollectionCell.self,
                            forCellWithReuseIdentifier: "\(TrackerColorCollectionCell.self)")
        collection.register(WrapperCollectionCell.self,
                            forCellWithReuseIdentifier: "\(WrapperCollectionCell.self)")
        collection.register(YPSectionHeaderCollectionView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: "\(YPSectionHeaderCollectionView.self)")

        collection.delegate = self
        collection.dataSource = self

        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayBold, size: 32)
        label.textAlignment = .center

        let localizedFormat = NSLocalizedString("days", comment: "Number of days")
        let daysCountLabel = String(format: localizedFormat, numberOfDays)
        label.text = daysCountLabel

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var createButton: UIButton = {
        let button = YPButton(
            label: NSLocalizedString("trackers.edit.save",
                                     comment: "Button label for updating tracker")
        )
        button.addTarget(self, action: #selector(save), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = YPButton(
            label: NSLocalizedString("trackers.edit.cancel",
                                     comment: "Button label for cancelling tracker edit"),
            style: .destructive
        )
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
}

// MARK: - Actions

private extension EditViewController {
    func onSchedule() {
        let scheduleVC = ScheduleViewController(repo: newTrackerRepository)
        navigationController?.pushViewController(scheduleVC, animated: true)
    }

    func onCategory() {
        let viewModel = TrackerCategoryViewModel(
            deps: .init(repo: trackerStore, newTrackerRepository: newTrackerRepository)
        ) { [weak self] in
            guard let self else { return }
            let newCategoryVC = NewCategoryViewController(store: self.trackerStore)
            self.navigationController?.pushViewController(newCategoryVC, animated: true)
        }

        let categoryVC = TrackerCategoryViewController(viewModel: viewModel)

        navigationController?.pushViewController(categoryVC, animated: true)
    }

    @objc func save() {
        guard let trackerName, let selectedColor, let selectedEmoji, let selectedCategory else {
            assertionFailure("Button should be disabled")
            return
        }

        tracker.label = trackerName
        tracker.emoji = selectedEmoji
        tracker.color = selectedColor
        tracker.schedule = type == .habit ? schedule : nil

        trackerStore.updateTracker(tracker, withCategory: selectedCategory.id)
        dismiss(animated: true)
    }

    @objc func cancel() {
        dismiss(animated: true)
    }

    func tapEmoji(at path: IndexPath) {
        let newEmoji = Emoji.list[path.row]
        guard selectedEmoji != newEmoji else { return }

        if
            let selectedEmoji,
            let index = Emoji.list.firstIndex(of: selectedEmoji),
            let oldCell = collectionView.cellForItem(
                at: .init(row: index, section: path.section-1)
            ) as? TrackerEmojiCollectionCell {

            oldCell.configure(selectedEmoji, isSelected: false)
        }

        if let newCell = collectionView.cellForItem(at: path) as? TrackerEmojiCollectionCell {
            newCell.configure(newEmoji, isSelected: true)
        }

        selectedEmoji = newEmoji
    }

    func tapColor(at path: IndexPath) {
        let newColor = TrackerColor.allCases[path.row]
        guard selectedColor != newColor else { return }

        if
            let selectedColor,
            let index = TrackerColor.allCases.firstIndex(of: selectedColor),
            let oldCell = collectionView.cellForItem(
                at: .init(row: index, section: path.section-1)
            ) as? TrackerColorCollectionCell {

            oldCell.configure(selectedColor.uiColor, isSelected: false)
        }

        if let newCell = collectionView.cellForItem(at: path) as? TrackerColorCollectionCell {
            newCell.configure(newColor.uiColor, isSelected: true)
        }

        selectedColor = newColor
    }

    func tapLink(at path: IndexPath) {
        guard let property = Property(rawValue: path.row) else {
            assertionFailure("Can't happened")
            return
        }

        switch property {
        case .schedule:
            onSchedule()
        case .category:
            onCategory()
        }
    }

    func updateButtonStatus() {
        let isScheduleOK = type == .event || !schedule.isEmpty
        let isNameOK = trackerName != nil && trackerName != ""
        let isColorOK = selectedColor != nil
        let isEmojiOK = selectedEmoji != nil
        let isCategoryOk = selectedCategory != nil

        createButton.isEnabled = isScheduleOK && isNameOK && isColorOK && isEmojiOK && isCategoryOk
    }
}

// MARK: - UICollectionViewDelegate

extension EditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section-1) else { return }

        switch section {
        case .emojis:
            tapEmoji(at: indexPath)
        case .colors:
            tapColor(at: indexPath)
        case .properties:
            tapLink(at: indexPath)
        case .controls, .name:
            return
        }
    }
}

// MARK: - UICollectionViewDataSource

extension EditViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count + 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard section > 0 else { return 1 }
        guard let section = Section(rawValue: section-1) else { return 0 }

        switch section {
        case .name: return 1
        case .properties: return relevantProperties.count
        case .emojis: return Emoji.list.count
        case .colors: return TrackerColor.allCases.count
        case .controls: return Control.allCases.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard indexPath.section > 0 else { return getCountCell(collectionView, path: indexPath) }
        guard let section = Section(rawValue: indexPath.section-1) else {
            fatalError("Unknown section")
        }

        switch section {
        case .name: return getInputCell(collectionView, path: indexPath)
        case .properties: return getLinkCell(collectionView, path: indexPath)
        case .emojis: return getEmojiCell(collectionView, path: indexPath)
        case .colors: return getColorCell(collectionView, path: indexPath)
        case .controls: return getControlCell(collectionView, path: indexPath)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "\(YPSectionHeaderCollectionView.self)",
                for: indexPath
            ) as? YPSectionHeaderCollectionView
        else { fatalError("Something went terribly wrong") }

        view.titleLabel.text = Section(rawValue: indexPath.section-1)?.label

        return view
    }
}

// MARK: - Cell Configuration

private extension EditViewController {
    func getInputCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(YPInputCollectionCell.self)",
            for: path
        ) as? YPInputCollectionCell else { fatalError("Something went terribly wrong") }

        cell.configure(
            text: trackerName,
            placeholder: NSLocalizedString("trackers.edit.textPlaceholder",
                                           comment: "Placeholder when name field is empty"),
            outCorner: [.all]
        ) { [weak self] input in
            self?.trackerName = input
        }

        return cell
    }

    func getLinkCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collection.dequeueReusableCell(
                withReuseIdentifier: "\(YPLinkCollectionCell.self)",
                for: path
            ) as? YPLinkCollectionCell,
            let property = Property(rawValue: path.row)
        else { fatalError("Something went terribly wrong") }

        let description: String?
        switch property {
        case .category:
            description = selectedCategory?.label
        case .schedule:
            description = schedule.shortDescription
        }

        let isFirstCell = path.row == 0
        let isLastCell = path.row == relevantProperties.count - 1

        cell.configure(
            label: property.label,
            description: description,
            outCorner: (isFirstCell ? [.top] : []) + (isLastCell ? [.bottom] : []),
            hasDivider: !isLastCell
        )

        return cell
    }

    func getEmojiCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(TrackerEmojiCollectionCell.self)",
            for: path
        ) as? TrackerEmojiCollectionCell else { preconditionFailure("Something went terribly wrong") }

        let emoji = Emoji.list[path.row]

        cell.configure(emoji, isSelected: selectedEmoji == emoji)

        return cell
    }

    func getColorCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(TrackerColorCollectionCell.self)",
            for: path
        ) as? TrackerColorCollectionCell else { preconditionFailure("Something went terribly wrong") }

        let color = TrackerColor.allCases[path.row]
        cell.configure(color.uiColor, isSelected: selectedColor == color)

        return cell
    }

    func getControlCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard
            let control = Control(rawValue: path.row),
            let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(WrapperCollectionCell.self)",
            for: path
        ) as? WrapperCollectionCell else { preconditionFailure("Something went terribly wrong") }

        switch control {
        case .cancel: cell.configure(view: cancelButton)
        case .submit: cell.configure(view: createButton)
        }

        return cell
    }

    func getCountCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(WrapperCollectionCell.self)",
            for: path
        ) as? WrapperCollectionCell else { preconditionFailure("Something went terribly wrong") }

        cell.configure(view: countLabel)

        return cell
    }
}
