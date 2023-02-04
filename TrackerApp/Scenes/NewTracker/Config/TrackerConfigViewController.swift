import UIKit

final class TrackerConfigViewController: UIViewController {
    private let categories: [TrackerCategory]
    private let type: TrackerType
    private let onCreate: (Tracker, TrackerCategory) -> Void

    private var schedule: Set<WeekDay> = .mockEveryDay
    private var trackerName: String?
    private var selectedCategory: TrackerCategory?

    private let collectionInsets = UIEdgeInsets(top: 24, left: 15, bottom: 16, right: 15)

    init(
        _ type: TrackerType,
        categories: [TrackerCategory],
        onCreate: @escaping (Tracker, TrackerCategory) -> Void
    ) {
        self.type = type
        self.categories = categories
        self.onCreate = onCreate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .asset(.white)

        title = "Новая привычка"
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
            forCellWithReuseIdentifier: "\(YPInputCollectionCell.self)"
        )

        collection.register(
            YPLinkCollectionCell.self,
            forCellWithReuseIdentifier: "\(YPLinkCollectionCell.self)")

        collection.register(
            TrackerCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(TrackerCategoryHeaderView.self)"
        )

        collection.delegate = self
        collection.dataSource = self

        collection.translatesAutoresizingMaskIntoConstraints = false

        return collection
    }()
}

// MARK: - Configuration

private extension TrackerConfigViewController {
    enum Section: Int, CaseIterable {
        case name, properties, emojis, colors, controls
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
    }

    enum Control: String, CaseIterable {
        case cancel = "Отменить"
        case submit = "Создать"
    }

    enum Emoji {
        static let list = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
            "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
        ]
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerConfigViewController: UICollectionViewDelegate {}

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
            return .init(top: 24, left: 0, bottom: 0, right: 0)
        default:
            return .zero
        }
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
            return Property.allCases.count
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
            let scheduleDescription = WeekDay.allCasesSortedForUserCalendar
                .filter { schedule.contains($0) }
                .map { $0.shortLabel }
                .joined(separator: ", ")
            description = scheduleDescription.isEmpty ? nil : scheduleDescription
        }

        cell.configure(
            label: property.label,
            description: description,
            outCorner: path.row == 0
                ? [.top]
                : path.row == Property.allCases.count - 1
                    ? [.bottom]
                    : []
        )

        return cell
    }

    func getEmojiCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(YPInputCollectionCell.self)",
            for: path
        ) as? YPInputCollectionCell else { fatalError("Something went terribly wrong") }

        return cell
    }

    func getColorCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(YPInputCollectionCell.self)",
            for: path
        ) as? YPInputCollectionCell else { fatalError("Something went terribly wrong") }

        return cell
    }

    func getControlCell(_ collection: UICollectionView, path: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(
            withReuseIdentifier: "\(YPInputCollectionCell.self)",
            for: path
        ) as? YPInputCollectionCell else { fatalError("Something went terribly wrong") }

        return cell
    }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct TrackerConfigViewController_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .foregroundColor(.black)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: .constant(true)) {
                
            UIViewControllerPreview {
                let rootVC = TrackerConfigViewController(.habit, categories: [.mockHome]) { _, _ in }
                let viewController = UINavigationController(rootViewController: rootVC)
                viewController.configureForModal()
                return viewController
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
#endif
