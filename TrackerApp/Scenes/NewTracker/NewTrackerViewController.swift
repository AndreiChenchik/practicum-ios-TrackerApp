import UIKit

enum TrackerType {
    case habit, event
}

final class NewTrackerViewController: UIViewController {
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    private let type: TrackerType
    private let categories: [TrackerCategory]
    private var schedule: Set<WeekDay> = []

    private let onCreate: (Tracker, TrackerCategory) -> Void

    init(
        _ type: TrackerType,
        categories: [TrackerCategory],
        onCreate: @escaping (Tracker, TrackerCategory) -> Void
    ) {
        self.type = type
        self.categories = categories
        self.onCreate = onCreate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = "Новая привычка"
        setupAppearance()
    }

    // MARK: Components

    private lazy var createButton: UIButton = {
        let button = YPButton(label: "Готово")
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = YPButton(label: "Отменить", destructive: true)
        button.addTarget(self, action: #selector(create), for: .touchUpInside)

        return button
    }()

    private lazy var scheduleButton: DisclosureButton = {
        let button = DisclosureButton(label: "Расписание")
        button.addTarget(self, action: #selector(changeSchedule), for: .touchUpInside)

        return button
    }()

    private lazy var textInput: UITextField = {
        let input = UITextField()

        input.backgroundColor = .asset(.background).withAlphaComponent(0.3)
        input.font = .asset(.ysDisplayRegular, size: 17)
        input.placeholder = "Введите название трекера"
        input.clearButtonMode = .always

        let spacerView = UIView(frame: .init(origin: .zero, size: .init(width: 16, height: 1)))
        input.leftViewMode = .always
        input.leftView = spacerView

        input.layer.cornerRadius = 10
        input.layer.masksToBounds = true

        input.addTarget(self, action: #selector(textChanged), for: .allEditingEvents)

        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
}

// MARK: - Actions

private extension NewTrackerViewController {
    @objc func changeSchedule() {
        let scheduleVC = ScheduleViewController(schedule) { [weak self] newSchedule in
            guard let self else { return }

            self.schedule = newSchedule

            let selectedDays = WeekDay.allCases
                .filter { newSchedule.contains($0) }
                .map { $0.shortLabel }
                .joined(separator: ", ")

            self.scheduleButton.setDescription(selectedDays.isEmpty ? nil : selectedDays)
        }

        updateButtonStatus()

        navigateTo(scheduleVC)
    }

    @objc func textChanged(_ sender: UITextInput) {
        updateButtonStatus()
    }

    func updateButtonStatus() {
        let isScheduleOK = type == .event || !schedule.isEmpty
        let isInputOK = textInput.text != nil && textInput.text != ""

        createButton.isEnabled = isScheduleOK && isInputOK
    }

    func navigateTo(_ viewController: UIViewController) {
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }

    @objc func create() {
        guard let text = textInput.text else {
            assertionFailure("Button should be disabled")
            return
        }

        let newTracker = Tracker(
            label: text,
            emoji: emojis.randomElement()!,
            color: TrackerColor.allCases.randomElement()!,
            schedule: type == .habit ? schedule : nil
        )

        onCreate(newTracker, categories[0])

        dismiss(animated: true)
    }

    @objc func cancel() {
        dismiss(animated: true)
    }
}

// MARK: - Appearance

private extension NewTrackerViewController {
    func setupAppearance() {
        navigationItem.hidesBackButton = true

        view.backgroundColor = .asset(.white)

        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 8
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        hStack.addArrangedSubview(cancelButton)
        hStack.addArrangedSubview(createButton)

        view.addSubview(hStack)
        view.addSubview(textInput)

        let safeArea = view.safeAreaLayoutGuide

        if type == .habit { addScheduleButton() }

        NSLayoutConstraint.activate([
            textInput.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            textInput.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            textInput.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            textInput.heightAnchor.constraint(equalToConstant: 75),
            hStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            hStack.heightAnchor.constraint(equalToConstant: 60),
            hStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])
    }

    func addScheduleButton() {
        view.addSubview(scheduleButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scheduleButton.topAnchor.constraint(equalTo: textInput.bottomAnchor, constant: 24),
            scheduleButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
    }
}
