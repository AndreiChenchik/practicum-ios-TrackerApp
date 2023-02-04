import UIKit

final class YPLinkCollectionCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

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

    private lazy var cell = CellView(content: chevronView)
    private lazy var chevronView: UIImageView = {
        let view = UIImageView()

        view.image = .asset(.chevronIcon)
        view.tintColor = .asset(.gray)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func configure(
        label: String?,
        description: String?,
        outCorner: [CellCorner],
        hasDivider: Bool
    ) {
        cell.update(
            label: label,
            description: description,
            outCorner: outCorner,
            hasDivider: hasDivider
        )
    }

    func setDescription(_ description: String?) {
        cell.updateDescription(description)
    }

    override func prepareForReuse() {
        configure(label: nil, description: nil, outCorner: [], hasDivider: false)
    }
}
