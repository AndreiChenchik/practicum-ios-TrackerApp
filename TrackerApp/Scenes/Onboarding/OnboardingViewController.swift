import UIKit

final class OnboardingViewController: UIPageViewController {

    private var pages: [UIViewController] = []

    private let messages = [
        (text: "Отслеживайте только то, что хотите", image: ImageAsset.onboarding1),
        (text: "Даже если это\nне литры воды и йога", image: ImageAsset.onboarding2)
    ]

    private var isSwitchingPages = false
    private var selectedPage: Int? {
        didSet {
            if selectedPage != oldValue {
                updateState()
            }
        }
    }

    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey: Any]? = nil
    ) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: navigationOrientation,
            options: options
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        setupPageView()
        setupActions()
    }

    private func setupPageView() {
        dataSource = self
        delegate = self

        pages = messages.map { OnboardingPageViewController(text: $0.text) }
        pageControl.numberOfPages = pages.count

        selectedPage = 0
    }

    // MARK: Components

    private let pageControl: UIPageControl = {
        let control = UIPageControl()

        control.currentPageIndicatorTintColor = .asset(.black)
        control.pageIndicatorTintColor = .asset(.black).withAlphaComponent(0.3)

        control.translatesAutoresizingMaskIntoConstraints = false

        return control
    }()

    private let button = YPButton(label: "Вот это технологии!")

    private let pageBackground: UIImageView = {
        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
}

// MARK: - Page Switching

private extension OnboardingViewController {

    var displayedPageIndex: Int? {
        guard let viewController = viewControllers?.first else { return nil }
        return pages.firstIndex(of: viewController)
    }

    func updateState() {
        guard
            let selectedPage,
            selectedPage >= 0,
            selectedPage < pages.count
        else { return }

        syncPage(selectedPage)
        syncBackground(selectedPage)
        syncPageControl(selectedPage)
    }

    func syncPage(_ index: Int) {
        guard !isSwitchingPages, index != displayedPageIndex else { return }

        isSwitchingPages = true

        setViewControllers([pages[index]], direction: .forward, animated: true) { [weak self] _ in
            guard let self else { return }
            self.isSwitchingPages = false
            self.syncPage(self.selectedPage ?? index)
        }
    }

    func syncBackground(_ index: Int) {
        let asset = messages[index].image

        UIView.transition(
            with: pageBackground,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) { [weak self] in
            self?.pageBackground.image = .asset(asset)
        }
    }

    func syncPageControl(_ index: Int) {
        pageControl.currentPage = index
    }
}

// MARK: - Components Configuration

private extension OnboardingViewController {

    func configureViews() {
        view.backgroundColor = .asset(.white)
        pageControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)

        view.addSubview(pageControl)
        view.addSubview(button)
        view.insertSubview(pageBackground, at: 0)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -124),
            button.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -50),
            pageBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageBackground.topAnchor.constraint(equalTo: view.topAnchor),
            pageBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - User Action

private extension OnboardingViewController {
    func setupActions() {
        pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc func pageControlChanged(_ sender: UIPageControl) {
        selectedPage = sender.currentPage
    }

    @objc func buttonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = (index - 1 + pages.count) % pages.count
        return pages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = (index + 1) % pages.count
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        selectedPage = displayedPageIndex
    }
}
