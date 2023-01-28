//
//  OnboardingViewController.swift
//  TrackerApp
//
//  Created by Andrei Chenchik on 22/1/23.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    var pages = [UIViewController]()
    let pageControl = UIPageControl() // external - not part of underlying pages
    let initialPage = 0

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
        view.backgroundColor = .asset(.white)

        setup()
        style()
        layout()
    }
}

extension OnboardingViewController {

    func setup() {
        dataSource = self
        delegate = self

        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)

        // create an array of viewController
        let page1 = OnboardingPageViewController(text: "Отслеживайте только то, что хотите")
        let page2 = OnboardingPageViewController(text: "Даже если это \nне литры воды и йога")

        pages.append(page1)
        pages.append(page2)

        // set initial viewController to be displayed
        // Note: We are not passing in all the viewControllers here. Only the one to be displayed.
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
    }

    func style() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .systemGray2
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
    }

    func layout() {
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 1),
        ])
    }
}

// MARK: - Actions

extension OnboardingViewController {

    // How we change page when pageControl tapped.
    // Note - Can only skip ahead on page at a time.
    @objc func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true, completion: nil)
    }
}

// MARK: - DataSources

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }

        if currentIndex == 0 {
            return pages.last               // wrap to last
        } else {
            return pages[currentIndex - 1]  // go previous
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }

        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1]  // go next
        } else {
            return pages.first              // wrap to first
        }
    }
}

// MARK: - Delegates

extension OnboardingViewController: UIPageViewControllerDelegate {

    // How we keep our pageControl in sync with viewControllers
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }

        pageControl.currentPage = currentIndex
    }
}
