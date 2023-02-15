import UIKit

final class CategoryTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(cell)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cell.frame = bounds.insetBy(dx: 16, dy: 0)
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
