import UIKit

extension UIButton {
    static func yButton(label: String) -> UIButton {
        let button = UIButton()

        button.setTitle(label, for: .normal)
        button.titleLabel?.font = .asset(.ysDisplayMedium, size: 16)
        button.backgroundColor = .asset(.black)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }
}
