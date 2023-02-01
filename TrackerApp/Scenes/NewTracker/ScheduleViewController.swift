import UIKit

final class ScheduleViewController: UIViewController {
    private let completion: (Set<WeekDay>) -> Void
    private var schedule: Set<WeekDay>

    private var items: [WeekDay] { WeekDay.allCasesSortedForUserCalendar }

    init(
        _ schedule: Set<WeekDay>,
        completion: @escaping (Set<WeekDay>) -> Void
    ) {
        self.schedule = schedule
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = "Расписание"
        setupAppearance()
    }

    // MARK: Components

    private lazy var tableView: UITableView = {
        let table = UITableView()

        table.register(ScheduleViewCell.self, forCellReuseIdentifier: "cell")

        table.separatorInset = .init(top: 0, left: 32, bottom: 0, right: 32)
        table.separatorColor = .asset(.gray)

        table.delegate = self
        table.dataSource = self

        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private lazy var doneButton: UIButton = {
        let button = YPButton(label: "Готово")
        button.addTarget(self, action: #selector(done), for: .touchUpInside)

        return button
    }()
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ScheduleViewCell

        let day = items[indexPath.row]
        let isOn = schedule.contains(day)

        if isOn {
            schedule.remove(day)
        } else {
            schedule.insert(day)
        }

        cell?.setOn(!isOn)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath)

        guard let scheduleCell = cell as? ScheduleViewCell else {
            assertionFailure("Can't get cell for ImagesList")
            return .init()
        }

        let day = items[indexPath.row]

        scheduleCell.configure(
            label: day.label,
            isOn: schedule.contains(day),
            type: indexPath.row == 0
                ? .first
                : indexPath.row == items.count - 1
                    ? .last
                    : nil
        )

        return scheduleCell
    }
}

// MARK: - Appearance

private extension ScheduleViewController {
    func setupAppearance() {
        navigationItem.hidesBackButton = true

        view.backgroundColor = .asset(.white)

        view.addSubview(doneButton)
        view.addSubview(tableView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -39)
        ])

        tableView.tableFooterView = .init()
    }
}

// MARK: - Actions

private extension ScheduleViewController {
    @objc func done() {
        completion(schedule)

        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
