import UIKit

extension UICollectionViewCompositionalLayout {
    static var trackers: Self {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                            heightDimension: .absolute(148)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(10)),
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(9)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 16, bottom: 16, trailing: 16)

        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                    heightDimension: .estimated(19)),
                  elementKind: UICollectionView.elementKindSectionHeader,
                  alignment: .topLeading)
        ]

        return .init(section: section)
    }
}
