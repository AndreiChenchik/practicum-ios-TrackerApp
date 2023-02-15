import UIKit

final class TrackerColorCollectionCell: UICollectionViewCell {
    private lazy var background: UIView = {
        let view = UIView()

        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.asset(.black).withAlphaComponent(0.3).cgColor

        view.layer.cornerRadius = 12
        view.clipsToBounds = true

        return view
    }()

    private lazy var colorView: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 8
        view.clipsToBounds = true

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(background)
        addSubview(colorView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        background.frame = bounds
        colorView.frame = bounds.insetBy(dx: 6, dy: 6)
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
        VStack {
            UIViewPreview {
                let view = TrackerColorCollectionCell()
                view.configure(.red, isSelected: true)
                return view
            }
            .frame(width: 52, height: 52)

            UIViewPreview {
                let view = TrackerColorCollectionCell()
                view.configure(.red, isSelected: true)
                return view
            }
            .frame(width: 100, height: 52)

            UIViewPreview {
                let view = TrackerColorCollectionCell()
                view.configure(.red, isSelected: true)
                return view
            }
            .frame(width: 200, height: 100)
        }
    }
}
#endif
