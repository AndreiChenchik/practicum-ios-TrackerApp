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

        var onboardingVC: OnboardingViewController?
        if !UserDefaults.standard.bool(forKey: "isOnboardingShown") {
            onboardingVC = .init()
            UserDefaults.standard.setValue(true, forKey: "isOnboardingShown")
        }

        let home = HomeViewController(onboarding: onboardingVC)

        window.rootViewController = home

        self.window = window
        window.makeKeyAndVisible()
    }
}
