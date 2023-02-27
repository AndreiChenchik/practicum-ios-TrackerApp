import UIKit

enum CornerCellType {
    case first, last
}

final class ScheduleViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        addSubview(labelView)
        addSubview(toggleView)
        insertSubview(backView, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backView.frame = bounds.insetBy(dx: 16, dy: 0)
        labelView.frame = bounds.insetBy(dx: 32, dy: 0)
        toggleView.frame = .init(
            origin: .init(x: bounds.width - toggleView.frame.width - 32,
                          y: (bounds.height - toggleView.frame.height) / 2),
            size: toggleView.frame.size)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        .init(width: size.width, height: 75)
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
        super.prepareForReuse()
        configure()
    }

    private lazy var toggleView: UISwitch = {
        let toggle = UISwitch()

        toggle.onTintColor = .asset(.blue)

        return toggle
    }()

    private lazy var labelView: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayRegular, size: 17)
        label.textColor = .asset(.black)

        return label
    }()

    private lazy var backView: UIView = {
        let view = UIView()

        view.backgroundColor = .asset(.background).withAlphaComponent(0.3)

        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = []

        return view
    }()
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct View_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = ScheduleViewCell()
            view.configure(label: "Test", isOn: true, type: .last)
            return view
        }
        .frame(height: 75)
    }
}
#endif
