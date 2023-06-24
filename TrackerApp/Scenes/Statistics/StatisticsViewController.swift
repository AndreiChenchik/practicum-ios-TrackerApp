import UIKit

final class StatisticsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("statistics.title", comment: "Screen title")

        addPlaceholder()
    }

    // MARK: - Components

    private lazy var placeholderView: UIView = .placeholderView(
        message: NSLocalizedString(
            "statistics.no_data",
            comment: "Placeholder text when there are no stats"
        ),
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
