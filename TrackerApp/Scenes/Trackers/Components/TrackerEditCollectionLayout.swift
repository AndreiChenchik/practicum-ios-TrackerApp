import UIKit

extension UICollectionViewCompositionalLayout {
    static var trackerEdit: UICollectionViewCompositionalLayout {
        typealias Section = TrackerConfigViewController.Section

        return .init { sectionIndex, _ in
            guard sectionIndex > 0 else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                    heightDimension: .absolute(38)))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(10)),
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 24,
                                              leading: 16,
                                              bottom: 24,
                                              trailing: 16)

                return section
            }
            guard let collectionSection = Section(rawValue: sectionIndex-1) else { return nil }

            switch collectionSection {
            case .name, .properties:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                    heightDimension: .absolute(75)))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(10)),
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 24,
                                              leading: 16,
                                              bottom: collectionSection == .properties ? 32 : 0,
                                              trailing: 16)

                return section

            case .emojis, .colors:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(52),
                                                                    heightDimension: .absolute(52)))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(10)),
                    subitems: [item]
                )
                group.interItemSpacing = .flexible(0)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 18, leading: 19, bottom: 40, trailing: 19)

                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                            heightDimension: .estimated(19)),
                          elementKind: UICollectionView.elementKindSectionHeader,
                          alignment: .topLeading)
                ]

                return section

            case .controls:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                    heightDimension: .absolute(60)))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(60)),
                    subitem: item,
                    count: 2
                )
                group.interItemSpacing = .fixed(8)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)

                return section
            }
        }
    }
}
