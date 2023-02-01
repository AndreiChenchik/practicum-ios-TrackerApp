import UIKit

final class TrackerCategoryHeaderView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayBold, size: 19)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        configure(label: nil)
    }

    func configure(label: String?) {
        titleLabel.text = label
    }
}
