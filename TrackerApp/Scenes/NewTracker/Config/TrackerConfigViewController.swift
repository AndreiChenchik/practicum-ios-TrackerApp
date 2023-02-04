import UIKit

final class TrackerConfigCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let cell = CellView(outCorner: [.all])
        cell.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cell)
        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: topAnchor),
            cell.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class TrackerConfigViewController: UIViewController {
    private let type: TrackerType
    private let categories: [TrackerCategory]
    private var schedule: Set<WeekDay> = []

    private let collectionInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)

    private let onCreate: (Tracker, TrackerCategory) -> Void

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

        collection.register(TrackerConfigCell.self, forCellWithReuseIdentifier: "cell")

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

    enum Property: String, CaseIterable {
        case category = "Категория"
        case schedule = "Расписание"
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

extension TrackerConfigViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.frame.width - collectionInsets.left - collectionInsets.right,
            height: 50
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct TrackerConfigViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let rootVC = TrackerConfigViewController(.habit, categories: [.mockHome]) { _, _ in }
            let viewController = UINavigationController(rootViewController: rootVC)
            viewController.configureForModal()
            return viewController
        }
    }
}
#endif
