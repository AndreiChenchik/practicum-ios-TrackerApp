import UIKit

final class TrackerViewController: UIViewController {

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
        view.backgroundColor = .asset(.white)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentOnboarding()
    }
}

private extension TrackerViewController {
    func presentOnboarding() {
        if let onboarding {
            onboarding.modalPresentationStyle = .overFullScreen
            present(onboarding, animated: false)
            self.onboarding = nil
        }
    }
}
