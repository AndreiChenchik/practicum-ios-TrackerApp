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

    private var trackerLabelView: TrackerLabelView = {
        let view = TrackerLabelView()

        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var dayLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 1
        label.font = .asset(.ysDisplayMedium, size: 12)
        label.textColor = .asset(.black)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}

// MARK: - Configuration

extension TrackerCollectionViewCell {
    func configure(with model: Tracker?) {
        trackerLabelView.configure(with: model)

        let localizedFormat = NSLocalizedString("days", comment: "Number of days")
        let daysCountLabel = String(format: localizedFormat, model?.completedCount ?? 0)
        dayLabel.text = daysCountLabel

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
        contentView.addSubview(trackerLabelView)
        contentView.addSubview(dayLabel)

        NSLayoutConstraint.activate([
            trackerLabelView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerLabelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerLabelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.topAnchor.constraint(equalTo: trackerLabelView.bottomAnchor, constant: 8),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor)
        ])
    }
}
