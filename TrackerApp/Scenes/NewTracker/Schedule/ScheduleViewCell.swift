import UIKit

enum CornerCellType {
    case first, last
}

final class ScheduleViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOn(_ isOn: Bool) {
        toggleView.setOn(isOn, animated: true)
    }

    func configure(label: String? = nil, isOn: Bool = false, type: CornerCellType? = nil) {
        labelView.text = label

        setOn(isOn)

        backView.layer.maskedCorners = type == .first
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            : type == .last
                ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                : []

        if type == .last {
            separatorInset = .init(top: 0, left: .infinity, bottom: 0, right: 0)
        }
    }

    override func prepareForReuse() {
        configure()
    }

    private lazy var toggleView: UISwitch = {
        let toggle = UISwitch()

        toggle.onTintColor = .asset(.blue)

        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private lazy var labelView: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayRegular, size: 17)
        label.textColor = .asset(.black)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var backView: UIView = {
        let view = UIView()

        view.backgroundColor = .asset(.background).withAlphaComponent(0.3)

        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = []

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: - Appearance

private extension ScheduleViewCell {

    func setupAppearance() {
        backgroundColor = .clear
        selectionStyle = .none

        addSubview(labelView)
        addSubview(toggleView)
        insertSubview(backView, at: 0)

        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),
            labelView.topAnchor.constraint(equalTo: topAnchor, constant: 26.5),
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26.5),
            toggleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16)
        ])
    }
}
