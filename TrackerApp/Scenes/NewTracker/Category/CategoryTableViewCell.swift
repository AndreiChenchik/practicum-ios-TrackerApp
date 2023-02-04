import UIKit

final class CategoryTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        cell.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cell)

        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: topAnchor),
            cell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cell.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var cell = CellView(content: checkView)
    private lazy var checkView: UIImageView = {
        let view = UIImageView()

        view.image = .asset(.checkmarkIcon)
        view.tintColor = .asset(.blue)
        view.isHidden = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func configure(
        label: String?,
        isSelected: Bool = false,
        outCorner: [CellCorner],
        hasDivider: Bool
    ) {
        cell.update(
            label: label,
            outCorner: outCorner,
            hasDivider: hasDivider
        )

        if isSelected {
            checkView.fadeIn()
        } else {
            checkView.fadeOut()
        }
    }

    override func prepareForReuse() {
        configure(label: nil, outCorner: [], hasDivider: false)
    }
}
