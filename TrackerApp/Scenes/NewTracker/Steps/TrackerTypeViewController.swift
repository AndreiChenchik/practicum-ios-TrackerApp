import UIKit

final class TrackerTypeViewController: UIViewController {
    private let completion: (TrackerType) -> Void

    init(
        completion: @escaping (TrackerType) -> Void
    ) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = NSLocalizedString("newTracker.title", comment: "Screen title")
        setupAppearance()
    }

    // MARK: Components

    private lazy var habitButton: UIButton = {
        let button = YPButton(
            label: NSLocalizedString("newTracker.habit",
                                     comment: "Button label for creating new habit")
        )
        button.addTarget(self, action: #selector(addHabit), for: .touchUpInside)

        return button
    }()

    private lazy var eventButton: UIButton = {
        let button = YPButton(
            label: NSLocalizedString("newTracker.event",
                                     comment: "Button label for creating new event")
        )
        button.addTarget(self, action: #selector(addEvent), for: .touchUpInside)

        return button
    }()
}

// MARK: - Appearance

private extension TrackerTypeViewController {
    func setupAppearance() {
        navigationItem.hidesBackButton = true

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
        completion(.habit)
    }

    @objc func addEvent() {
        completion(.event)
    }
}
