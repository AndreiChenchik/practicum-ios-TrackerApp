import UIKit

final class StatisticsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика"

        addPlaceholder()
    }

    // MARK: - Components

    private lazy var placeholderView: UIView = {
        let label = UILabel()
        label.font = .asset(.ysDisplayMedium, size: 12)
        label.text = "Анализировать пока нечего"

        let icon = UIImageView()
        icon.image = .asset(.statsPlaceholder)

        let vStack = UIStackView()

        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .center

        vStack.addArrangedSubview(icon)
        vStack.addArrangedSubview(label)

        vStack.translatesAutoresizingMaskIntoConstraints = false

        return vStack
    }()
}

// MARK: - Appearance

private extension StatisticsViewController {
    func addPlaceholder() {
        view.addSubview(placeholderView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}
