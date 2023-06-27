import UIKit

final class StatisticsViewController: UIViewController {
    private var repo: TrackerStoring

    init(repo: TrackerStoring) {
        self.repo = repo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Components

    private lazy var placeholderView: UIView = .placeholderView(
        message: NSLocalizedString(
            "statistics.no_data",
            comment: "Placeholder text when there are no stats"
        ),
        icon: .statsPlaceholder
    )

    private lazy var bestPeriodView = StatisticsFactView()
    private lazy var idealDaysView = StatisticsFactView()
    private lazy var completedTrackersView = StatisticsFactView()
    private lazy var averageValueView = StatisticsFactView()
    private lazy var statsView: UIStackView = {
        let vStack = UIStackView(arrangedSubviews: [bestPeriodView,
                                                    idealDaysView,
                                                    completedTrackersView,
                                                    averageValueView])
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.isHidden = true

        vStack.translatesAutoresizingMaskIntoConstraints = false

        return vStack
    }()
}

// MARK: - Lifecycle

extension StatisticsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("statistics.title", comment: "Screen title")

        layoutViews()
        updateStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }
}

// MARK: - Appearance

private extension StatisticsViewController {
    func layoutViews() {
        view.addSubview(placeholderView)
        view.addSubview(statsView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            statsView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            statsView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            statsView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            statsView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            bestPeriodView.heightAnchor.constraint(equalTo: idealDaysView.heightAnchor),
            idealDaysView.heightAnchor.constraint(equalTo: completedTrackersView.heightAnchor),
            completedTrackersView.heightAnchor.constraint(equalTo: averageValueView.heightAnchor),
            averageValueView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}

// MARK: - Data

private extension StatisticsViewController {
    func updateStats() {
        if let stats = repo.statistics {
            bestPeriodView.update(
                fact: "\(stats.bestPeriod)",
                description: NSLocalizedString("stats.bestPeriod",
                                               comment: "Label for best period count")
            )
            idealDaysView.update(
                fact: "\(stats.idealDays)",
                description: NSLocalizedString("stats.idealDays",
                                               comment: "Label for ideal days count")
            )
            completedTrackersView.update(
                fact: "\(stats.completedTrackers)",
                description: NSLocalizedString("stats.completedTrackers",
                                               comment: "Label for completed trackers count")
            )
            averageValueView.update(
                fact: "\(stats.averageValue)",
                description: NSLocalizedString("stats.averageValue",
                                               comment: "Label for average value count")
            )

            placeholderView.isHidden = true
            statsView.isHidden = false
        } else {
            placeholderView.isHidden = false
            statsView.isHidden = true
        }
    }
}
