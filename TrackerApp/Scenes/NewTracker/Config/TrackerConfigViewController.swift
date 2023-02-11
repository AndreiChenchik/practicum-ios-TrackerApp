import UIKit
import Combine

final class TrackerConfigViewController: UIViewController {
    private let type: TrackerType

    private let onCreate: (Tracker, UUID) -> Void
    private let onCategory: () -> Void
    private let onSchedule: () -> Void

    private var schedule: Set<WeekDay> = [] { didSet { updateButtonStatus() } }
    private var trackerName: String? { didSet { updateButtonStatus() } }
    private var selectedCategory: TrackerCategory? { didSet { updateButtonStatus() } }
    private var selectedEmoji: String? { didSet { updateButtonStatus() } }
    private var selectedColor: TrackerColor? { didSet { updateButtonStatus() } }

    private let collectionInsets = UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)

    private var relevantProperties: [Property] {
        Property.allCases { $0 != .schedule || type == .habit }
    }

    private var cancellable: Set<AnyCancellable> = []

    init(
        _ type: TrackerType,
        selectedSchedule: Published<Set<WeekDay>>.Publisher,
        selectedCategory: Published<TrackerCategory?>.Publisher,
        onCreate: @escaping (Tracker, UUID) -> Void,
        onCategory: @escaping () -> Void,
        onSchedule: @escaping () -> Void
    ) {
        self.type = type
        self.onCreate = onCreate
        self.onCategory = onCategory
        self.onSchedule = onSchedule

        super.init(nibName: nil, bundle: nil)

        selectedSchedule
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.schedule = $0
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)

        selectedCategory
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.selectedCategory = $0
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .asset(.white)

        title = type == .habit ? "Новая привычка" : "Новое нерегулярное событие"
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
            collectionViewLayout: UICollectionViewFlowLayout()
        )

        collection.keyboardDismissMode = .onDrag
        collection.contentInset = collectionInsets

        collection.register(
            YPInputCollectionCell.self,
            forCellWithReuseIdentifier: "\(YPInputCollectionCell.self)")

        collection.register(
            YPLinkCollectionCell.self,
            forCellWithReuseIdentifier: "\(YPLinkCollectionCell.self)")

        collection.register(
            TrackerEmojiCollectionCell.self,
            forCellWithReuseIdentifier: "\(TrackerEmojiCollectionCell.self)")

        collection.register(
            TrackerColorCollectionCell.self,
            forCellWithReuseIdentifier: "\(TrackerColorCollectionCell.self)")

        collection.register(
            WrapperCollectionCell.self,
            forCellWithReuseIdentifier: "\(WrapperCollectionCell.self)")

        collection.register(
            YPSectionHeaderCollectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(YPSectionHeaderCollectionView.self)")

        collection.delegate = self
        collection.dataSource = self

        collection.translatesAutoresizingMaskIntoConstraints = false

        return collection
    }()

    private lazy var createButton: UIButton = {
        let button = YPButton(label: "Готово")
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = YPButton(label: "Отменить", destructive: true)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        return button
    }()
}

// MARK: - Actions

private extension TrackerConfigViewController {
    @objc func create() {
        guard let trackerName, let selectedColor, let selectedEmoji, let selectedCategory else {
            assertionFailure("Button should be disabled")
            return
        }

        let newTracker = Tracker(
            label: trackerName,
            emoji: selectedEmoji,
            color: selectedColor,
            schedule: type == .habit ? schedule : nil
        )

        onCreate(newTracker, selectedCategory.id)

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
                at: .init(row: index, section: path.section)
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
                at: .init(row: index, section: path.section)
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

extension TrackerConfigViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .emojis:
            tapEmoji(at: indexPath)
        case .colors:
            tapColor(at: indexPath)
        case .properties:
            tapLink(at: indexPath)
        default:
            return
        }
    }
}

// MARK: - Configuration

private extension TrackerConfigViewController {
    enum Section: Int, CaseIterable {
        case name, properties, emojis, colors, controls

        var label: String? {
            switch self {
            case .emojis:
                return "Emoji"
            case .colors:
                return "Цвет"
            default:
                return nil
            }
        }
    }

    enum Property: Int, CaseIterable {
        case category, schedule

        var label: String {
            switch self {
            case .category:
                return "Категория"
            case .schedule:
                return "Расписание"
            }
        }

        static func allCases(isIncluded: (Property) -> Bool) -> [Self] {
            Self.allCases.filter(isIncluded)
        }
    }

    enum Control: Int, CaseIterable {
        case cancel, submit

        var label: String {
            switch self {
            case .cancel:
                return "Отменить"
            case .submit:
                return "Создать"
            }
        }
    }

    enum Emoji {
        static let list = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
            "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
        ]
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerConfigViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let section = Section(rawValue: indexPath.section) else { return .zero }

        switch section {

        case .name, .properties:
            return CGSize(
                width: collectionView.frame.width - collectionInsets.left - collectionInsets.right,
                height: 75
            )

        case .emojis, .colors:
            return CGSize(width: 52, height: 52)

        case .controls:
            let margin = collectionInsets.left + collectionInsets.right
            let availableWidth = collectionView.frame.width - margin - 8

            return CGSize(
                width: availableWidth / 2,
                height: 60
            )
        }

    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        guard let section = Section(rawValue: section) else { return .zero }

        switch section {

        case .controls:
            return 8

        case .emojis, .colors:
            return 5

        default:
            return .zero

        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let section = Section(rawValue: section) else { return .zero }

        switch section {
        case .properties:
            return .init(top: 24, left: 0, bottom: 32, right: 0)
        case .emojis, .colors:
            return .init(top: 24, left: 0, bottom: 40, right: 0)
        case .controls:
            return .init(top: 6, left: 0, bottom: 0, right: 0)
        default:
            return .zero
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let footerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )

        return footerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerConfigViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .name:
            return 1
        case .properties:
            return relevantProperties.count
        case .emojis:
            return Emoji.list.count
        case .colors:
            return TrackerColor.allCases.count
        case .controls:
            return Control.allCases.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section")
        }

        switch section {
        case .name:
            return getInputCell(collectionView, path: indexPath)
        case .properties:
            return getLinkCell(collectionView, path: indexPath)
        case .emojis:
            return getEmojiCell(collectionView, path: indexPath)
        case .colors:
            return getColorCell(collectionView, path: indexPath)
        case .controls:
            return getControlCell(collectionView, path: indexPath)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            let section = Section(rawValue: indexPath.section),
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "\(YPSectionHeaderCollectionView.self)",
                for: indexPath
            ) as? YPSectionHeaderCollectionView
        else { fatalError("Something went terribly wrong") }

        view.titleLabel.text = section.label

        return view
    }
}

// MARK: - Cell Configuration

private extension TrackerConfigViewController {
    func getInputCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(YPInputCollectionCell.self)",
            for: path
        ) as? YPInputCollectionCell else { fatalError("Something went terribly wrong") }

        cell.configure(
            text: trackerName,
            placeholder: "Введите название трекера",
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
        case .cancel:
            cell.configure(view: cancelButton)
        case .submit:
            cell.configure(view: createButton)
        }

        return cell
    }
}
