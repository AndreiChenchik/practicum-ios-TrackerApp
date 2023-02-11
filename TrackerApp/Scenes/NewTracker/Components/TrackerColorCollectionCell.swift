import UIKit

final class TrackerColorCollectionCell: UICollectionViewCell {
    private lazy var background: UIView = {
        let view = UIView()

        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.asset(.black).withAlphaComponent(0.3).cgColor

        view.layer.cornerRadius = 12
        view.clipsToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var colorView: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 8
        view.clipsToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(background)
        addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            background.topAnchor.constraint(equalTo: topAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func configure(_ color: UIColor?, isSelected: Bool = false) {
        colorView.backgroundColor = color

        if isSelected {
            background.fadeIn()
        } else {
            background.fadeOut()
        }
    }

    override func prepareForReuse() {
        configure(nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct TrackerColorCollectionCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = TrackerColorCollectionCell()
            view.configure(.red, isSelected: true)
            return view
        }
        .frame(width: 52, height: 52)
    }
}
#endif
