import UIKit

class HomeViewController: UITabBarController {

    var onboarding: UIViewController?

    init(onboarding: UIViewController?) {
        self.onboarding = onboarding
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
        setupTabBarAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentOnboarding()
    }
}

// MARK: - Tabs

private extension HomeViewController {
    private func setupTabs() {
        let repository = TrackerRepository()
        let newTrackerCoordinator = TrackerCreationCoordinator(deps: .init(store: repository,
                                                                           newTrackerRepo: .init()))

        let trackersVC = TrackersViewController(repo: repository,
                                                creationCoordinator: newTrackerCoordinator)
        let statisticsVC = StatisticsViewController()

        let controllers = [UINavigationController(rootViewController: trackersVC),
                           UINavigationController(rootViewController: statisticsVC)]
        controllers.forEach(prepare)

        viewControllers = controllers

        if let listItem = tabBar.items?.first {
            listItem.image = .asset(.trackerTabIcon)
            listItem.title = "Трекеры"
        }

        if let profileItem = tabBar.items?.last {
            profileItem.image = .asset(.statisticsTabIcon)
            profileItem.title = "Статистика"
        }
    }
}

// MARK: - Appearance

private extension HomeViewController {
    func prepare(_ navigationController: UINavigationController) {
        navigationController.navigationBar.prefersLargeTitles = true

        navigationController.navigationBar.standardAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.asset(.black),
            NSAttributedString.Key.font: UIFont.asset(.ysDisplayBold, size: 34)
        ]
    }

    func setupTabBarAppearance() {
        view.backgroundColor = .asset(.white)

        let tabItemsAppearance = UITabBarItemAppearance()
        tabItemsAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.asset(.ysDisplayMedium, size: 10)
        ]

        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .asset(.white)
        appearance.stackedLayoutAppearance = tabItemsAppearance

        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.tintColor = .asset(.blue)
    }
}

// MARK: - Onboarding

private extension HomeViewController {
    func presentOnboarding() {
        if let onboarding {
            onboarding.modalPresentationStyle = .overFullScreen
            present(onboarding, animated: false)
            self.onboarding = nil
        }
    }
}
