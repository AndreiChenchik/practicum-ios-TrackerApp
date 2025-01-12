import UIKit

final class CellView: UIView {
    private let contentView: UIView

    init(
        content contentView: UIView = .init(),
        label: String? = nil,
        description: String? = nil,
        outCorner: [CellCorner] = [],
        hasDivider: Bool = false
    ) {
        self.contentView = contentView

        super.init(frame: .zero)

        backgroundColor = .asset(.background)

        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.maskedCorners = []

        addSubview(hStackView)
        addSubview(divider)
        hStackView.addArrangedSubview(contentView)

        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        update(label: label, description: description, outCorner: outCorner, hasDivider: hasDivider)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Components

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

    private lazy var vStackView: UIStackView = {
        let stack = UIStackView()

        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading

        stack.addArrangedSubview(labelView)

        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var hStackView: UIStackView = {
        let stack = UIStackView()

        stack.axis = .horizontal
        stack.alignment = .center

        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var spacer = UIView()

    private lazy var divider: UIView = {
        let view = UIView()

        view.backgroundColor = .asset(.gray)
        view.isHidden = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: - Updates

extension CellView {
    func update(
        label: String? = nil,
        description: String? = nil,
        outCorner: [CellCorner] = [],
        hasDivider: Bool = false
    ) {
        divider.isHidden = !hasDivider
        updateText(label: label, description: description)
        updateCorners(outCorner)
    }

    func updateDescription(_ description: String? = nil) {
        descriptionView.text = description

        if description != nil, vStackView.arrangedSubviews.count == 1 {
            vStackView.addArrangedSubview(descriptionView)
        } else if description == nil {
            vStackView.removeArrangedSubview(descriptionView)
        }
    }

    private func updateText(label: String?, description: String?) {
        labelView.text = label

        if label != nil || description != nil, hStackView.arrangedSubviews.count == 1 {
            hStackView.removeArrangedSubview(contentView)
            hStackView.addArrangedSubview(vStackView)
            hStackView.addArrangedSubview(spacer)
            hStackView.addArrangedSubview(contentView)
        } else if label == nil && description == nil {
            hStackView.removeArrangedSubview(vStackView)
            hStackView.removeArrangedSubview(spacer)
        }

        updateDescription(description)
    }

    private func updateCorners(_ corner: [CellCorner]) {
        layer.maskedCorners = corner.cornerMask
    }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            UIViewPreview {
                let text = UITextField()
                text.placeholder = "Type something"
                text.clearButtonMode = .always

                let view = CellView(content: text, outCorner: [.all])

                return view
            }
            .frame(height: 75)
            .padding(.bottom, 20)

            UIViewPreview {
                let view = CellView(
                    content: UISwitch(),
                    label: "Label",
                    description: "Description",
                    outCorner: [.top],
                    hasDivider: true
                )

                return view
            }
            .frame(height: 75)

            UIViewPreview {
                let view = CellView(
                    content: UISwitch(),
                    label: "Label",
                    description: "Description",
                    outCorner: [],
                    hasDivider: true
                )

                return view
            }
            .frame(height: 75)

            UIViewPreview {
                let view = CellView(
                    content: UISwitch(),
                    label: "Label",
                    description: nil,
                    outCorner: [],
                    hasDivider: true
                )

                return view
            }
            .frame(height: 75)

            UIViewPreview {
                let innerView = UIImageView()

                innerView.image = .asset(.checkmarkIcon)
                innerView.tintColor = .asset(.blue)

                let view = CellView(
                    content: innerView,
                    label: "Label",
                    description: "Has checkmark",
                    outCorner: [.bottom]
                )

                return view
            }
            .frame(height: 75)

        }
        .padding(20)
    }
}
#endif
