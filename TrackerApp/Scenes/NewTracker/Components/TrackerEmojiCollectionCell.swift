import UIKit

final class TrackerEmojiCollectionCell: UICollectionViewCell {
    private lazy var background: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .asset(.lightGray)

        return view
    }()

    private lazy var labelView: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayBold, size: 32)
        label.textAlignment = .center

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(background)
        addSubview(labelView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        background.frame = bounds
        labelView.frame = bounds
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
        VStack {
            UIViewPreview {
                let view = TrackerEmojiCollectionCell()
                view.configure("❤️", isSelected: true)
                return view
            }
            .frame(width: 52, height: 52)

            UIViewPreview {
                let view = TrackerEmojiCollectionCell()
                view.configure("❤️", isSelected: true)
                return view
            }
            .frame(width: 200, height: 52)

            UIViewPreview {
                let view = TrackerEmojiCollectionCell()
                view.configure("❤️", isSelected: true)
                return view
            }
            .frame(width: 200, height: 150)
        }
    }
}
#endif
