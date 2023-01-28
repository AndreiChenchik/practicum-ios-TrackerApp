import UIKit

final class OnboardingPageViewController: UIViewController {

    private let text: String

    private let textLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .asset(.ysDisplayBold, size: 32)
        label.textColor = .asset(.black)

        return label
    }()

    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        prepareLabel()
    }

    func prepareLabel() {
        textLabel.text = text

        view.addSubview(textLabel)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            textLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -270),
            textLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
    }
}
