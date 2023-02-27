import UIKit

extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.2) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = 1
        }
    }

    func fadeOut(_ duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = 0
        } completion: { [weak self] _ in
            self?.isHidden = true
        }
    }
}
