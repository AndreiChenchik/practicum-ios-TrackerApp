import UIKit

final class StatisticsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика"

        addPlaceholder()
    }

    // MARK: - Components

    private lazy var placeholderView: UIView = .placeholderView(
        message: "Анализировать пока нечего",
        icon: .statsPlaceholder
    )
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
