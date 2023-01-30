import UIKit

final class YPButton: UIButton {
    enum ButtonState {
        case normal
        case disabled
    }

    init(label: String, destructive: Bool = false) {
        super.init(frame: .zero)

        layer.borderColor = UIColor.asset(.red).cgColor
        layer.borderWidth = destructive ? 1 : 0
        backgroundColor = destructive ? .clear : .asset(.black)
        setTitleColor(destructive ? .asset(.red) : .asset(.white), for: .normal)
        titleLabel?.font = .asset(.ysDisplayMedium, size: 16)

        setTitle(label, for: .normal)

        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false

        if !destructive {
            setBackgroundColor(.asset(.black), for: .normal)
            setBackgroundColor(.asset(.gray), for: .disabled)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var disabledBackgroundColor: UIColor?
    private var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }

    override var isEnabled: Bool {
        didSet {
            if isEnabled, let defaultBackgroundColor {
               self.backgroundColor = defaultBackgroundColor
            }

            if !isEnabled, let disabledBackgroundColor {
                self.backgroundColor = disabledBackgroundColor
            }
        }
    }

    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .normal:
            defaultBackgroundColor = color
        }
    }
}
