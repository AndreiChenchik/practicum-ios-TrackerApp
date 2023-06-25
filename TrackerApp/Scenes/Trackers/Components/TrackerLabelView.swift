import UIKit

final class TrackerLabelView: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    // MARK: Components

    private var colorBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var trackerLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0
        label.font = .asset(.ysDisplayMedium, size: 12)
        label.textColor = .asset(.contrast)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var emojiLabel: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayMedium, size: 12)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var emojiBackground: UIView = {
        let view = UIView()

        view.backgroundColor = .asset(.contrast).withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: - Configuration

extension TrackerLabelView {
    func configure(with model: Tracker?) {
        trackerLabel.text = model?.label
        emojiLabel.text = model?.emoji
        colorBackground.backgroundColor = model?.color.uiColor
    }
}

// MARK: - Appearance

private extension TrackerLabelView {
    func setupAppearance() {
        addSubview(trackerLabel)
        addSubview(emojiLabel)

        insertSubview(emojiBackground, at: 0)
        insertSubview(colorBackground, at: 0)

        NSLayoutConstraint.activate([
            colorBackground.topAnchor.constraint(equalTo: topAnchor),
            colorBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorBackground.heightAnchor.constraint(equalToConstant: 90),
            emojiBackground.heightAnchor.constraint(equalTo: emojiBackground.widthAnchor),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            emojiBackground.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            trackerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: colorBackground.bottomAnchor, constant: -12)
        ])
    }
}
