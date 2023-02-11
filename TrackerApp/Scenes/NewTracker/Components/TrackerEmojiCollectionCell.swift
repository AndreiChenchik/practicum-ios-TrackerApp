import UIKit

final class TrackerEmojiCollectionCell: UICollectionViewCell {
    private lazy var background: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .asset(.lightGray)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var labelView: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayBold, size: 32)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(background)
        addSubview(labelView)

        NSLayoutConstraint.activate([
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelView.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.topAnchor.constraint(equalTo: topAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func configure(_ emoji: String?, isSelected: Bool = false) {
        labelView.text = emoji

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
struct TrackerEmojiCollectionCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = TrackerEmojiCollectionCell()
            view.configure("❤️", isSelected: true)
            return view
        }
        .frame(width: 52, height: 52)
    }
}
#endif
