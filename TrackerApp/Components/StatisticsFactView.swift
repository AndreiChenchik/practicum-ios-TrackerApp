import UIKit

final class StatisticsFactView: UIStackView {
    private lazy var factLabel: UILabel = {
        let label = UILabel()
        label.font = .asset(.ysDisplayBold, size: 34)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .asset(.ysDisplayMedium, size: 12)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedSubview(factLabel)
        addArrangedSubview(descriptionLabel)

        axis = .vertical
        spacing = 2
        alignment = .leading

        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)

        layer.borderWidth = 1
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let gradient = UIImage.gradientImage(bounds: bounds,
                                             colors: [.asset(.statisticsGradient1),
                                                      .asset(.statisticsGradient2),
                                                      .asset(.statisticsGradient3)])
        layer.borderColor = UIColor(patternImage: gradient).cgColor
    }

    func update(fact: String, description: String) {
        factLabel.text = fact
        descriptionLabel.text = description
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct StatisticsFact_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            UIViewPreview {
                let view = StatisticsFactView()
                view.update(fact: "6", description: "Лучший период")
                return view
            }
            .frame(height: 90)

            UIViewPreview {
                let view = StatisticsFactView()
                view.update(fact: "6", description: "Лучший период")
                return view
            }
            .frame(height: 90)

            UIViewPreview {
                let view = StatisticsFactView()
                view.update(fact: "6", description: "Лучший период")
                return view
            }
            .frame(height: 90)

            UIViewPreview {
                let view = StatisticsFactView()
                view.update(fact: "6", description: "Лучший период")
                return view
            }
            .frame(height: 90)

            Spacer()
        }
        .padding(16)
    }
}
#endif
