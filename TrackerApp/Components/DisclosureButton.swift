import UIKit

final class DisclosureButton: UIButton {
    init(label: String, description: String? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        labelView.text = label

        backgroundColor = .asset(.background).withAlphaComponent(0.3)

        layer.cornerRadius = 10
        layer.masksToBounds = true

        stackView.addArrangedSubview(labelView)

        if let description {
            descriptionView.text = description
            stackView.addArrangedSubview(descriptionView)
        }

        addSubview(stackView)
        addSubview(chevronView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    func setDescription(_ description: String? = nil) {
        descriptionView.text = description

        if description != nil, stackView.arrangedSubviews.count == 1 {
            stackView.addArrangedSubview(descriptionView)
        } else if description == nil {
            stackView.removeArrangedSubview(descriptionView)
        }
    }

    private lazy var labelView: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayRegular, size: 17)
        label.textColor = .asset(.black)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionView: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayRegular, size: 17)
        label.textColor = .asset(.gray)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronView: UIImageView = {
        let view = UIImageView()

        view.image = .asset(.chevronIcon)
        view.tintColor = .asset(.gray)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let vStack = UIStackView()

        vStack.axis = .vertical
        vStack.spacing = 2
        vStack.alignment = .leading

        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
