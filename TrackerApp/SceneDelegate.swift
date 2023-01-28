//
//  SceneDelegate.swift
//  TrackerApp
//
//  Created by Andrei Chenchik on 22/1/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let tracker = TrackerViewController(nibName: nil, bundle: nil)

        window.rootViewController = tracker

        self.window = window
        window.makeKeyAndVisible()

        showOnboarding(over: tracker)
    }
}

private extension SceneDelegate {
    func showOnboarding(over viewController: UIViewController) {
        let onboarding = OnboardingViewController()
        onboarding.modalPresentationStyle = .fullScreen
        viewController.present(onboarding, animated: false)
    }
}
