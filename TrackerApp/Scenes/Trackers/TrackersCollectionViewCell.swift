import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    weak var delegate: TrackersViewController?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: nil)
    }

    // MARK: Components

    private lazy var addButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.tintColor = .asset(.white)

        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var colorBackground: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var trackerLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0
        label.font = .asset(.ysDisplayMedium, size: 12)
        label.textColor = .asset(.white)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var dayLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 1
        label.font = .asset(.ysDisplayMedium, size: 12)
        label.textColor = .asset(.black)

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

        view.backgroundColor = .asset(.contrast)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: - Configuration

extension TrackerCollectionViewCell {
    func configure(with model: Tracker?) {
        trackerLabel.text = model?.label
        dayLabel.text = model != nil ? "\(model?.completedCount ?? 0) дней" : nil
        emojiLabel.text = model?.emoji

        colorBackground.backgroundColor = model?.color.uiColor
        addButton.backgroundColor = model?.color.uiColor
        addButton.isEnabled = model?.isCompleted != true
        addButton.layer.opacity = model?.isCompleted != true ? 1 : 0.3

        if model?.isCompleted != true {
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
    }
}

// MARK: - Actions

private extension TrackerCollectionViewCell {
    @objc func doneTapped() {
        delegate?.trackerMarkedCompleted(self)
    }
}

// MARK: - Appearance

private extension TrackerCollectionViewCell {
    func setupAppearance() {
        contentView.addSubview(addButton)
        contentView.addSubview(trackerLabel)
        contentView.addSubview(dayLabel)
        contentView.addSubview(emojiLabel)

        contentView.insertSubview(emojiBackground, at: 0)
        contentView.insertSubview(colorBackground, at: 0)

        NSLayoutConstraint.activate([
            colorBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorBackground.heightAnchor.constraint(equalToConstant: 90),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.topAnchor.constraint(equalTo: colorBackground.bottomAnchor, constant: 8),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            emojiBackground.heightAnchor.constraint(equalTo: emojiBackground.widthAnchor),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            trackerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: colorBackground.bottomAnchor, constant: -12),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor)
        ])
    }
}
