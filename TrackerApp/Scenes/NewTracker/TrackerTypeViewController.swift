import UIKit

final class TrackerTypeViewController: UIViewController {
    private let habitVC: UIViewController
    private let eventVC: UIViewController

    init(
        habitVC: UIViewController,
        eventVC: UIViewController
    ) {
        self.habitVC = habitVC
        self.eventVC = eventVC

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
        let button: UIButton = .yButton(label: "Привычка")
        button.addTarget(self, action: #selector(addHabit), for: .touchUpInside)

        return button
    }()

    private lazy var eventButton: UIButton = {
        let button: UIButton = .yButton(label: "Нерегулярные событие")
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
        navigationController?.pushViewController(habitVC, animated: true)
    }

    @objc func addEvent() {
        navigationController?.pushViewController(eventVC, animated: true)
    }
}
