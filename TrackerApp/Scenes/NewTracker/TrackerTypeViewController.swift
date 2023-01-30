import UIKit

final class TrackerTypeViewController: UIViewController {
    private let nextStepVC: (TrackerType) -> UIViewController

    init(
        nextStepVC: @escaping (TrackerType) -> UIViewController
    ) {
        self.nextStepVC = nextStepVC

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = "Создание трекера"
        setupAppearance()
    }

    // MARK: Components

    private lazy var habitButton: UIButton = {
        let button = YPButton(label: "Привычка")
        button.addTarget(self, action: #selector(addHabit), for: .touchUpInside)

        return button
    }()

    private lazy var eventButton: UIButton = {
        let button = YPButton(label: "Нерегулярные событие")
        button.addTarget(self, action: #selector(addEvent), for: .touchUpInside)

        return button
    }()
}

// MARK: - Appearance

private extension TrackerTypeViewController {
    func setupAppearance() {
        view.backgroundColor = .asset(.white)

        view.addSubview(habitButton)
        view.addSubview(eventButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            habitButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            eventButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            eventButton.heightAnchor.constraint(equalTo: habitButton.heightAnchor),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            eventButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -247)
        ])
    }
}

// MARK: - Actions

private extension TrackerTypeViewController {
    @objc func addHabit() {
        navigateTo(nextStepVC(.habit))
    }

    @objc func addEvent() {
        navigateTo(nextStepVC(.event))
    }

    func navigateTo(_ viewController: UIViewController) {
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }
}
