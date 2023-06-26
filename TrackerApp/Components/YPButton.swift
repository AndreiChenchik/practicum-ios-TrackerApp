import UIKit

final class YPButton: UIButton {
    enum ButtonStyle {
        case normal
        case destructive
        case prominent
    }

    enum ButtonState {
        case normal
        case disabled
    }

    init(label: String, style: ButtonStyle = .normal) {
        super.init(frame: .zero)

        contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)

        layer.borderColor = UIColor.asset(.red).cgColor
        layer.borderWidth = style == .destructive ? 1 : 0
        backgroundColor = style == .destructive ? .clear : .asset(.black)

        setTitleColor(style == .destructive
                        ? .asset(.red)
                        : style == .prominent
                            ? .asset(.contrast)
                            : .asset(.white),
                      for: .normal)
        titleLabel?.font = .asset(.ysDisplayMedium, size: 16)

        setTitle(label, for: .normal)

        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false

        if style != .destructive {
            let backgroundColor: UIColor = style == .prominent ? .asset(.blue) : .asset(.black)
            setBackgroundColor(backgroundColor, for: .normal)
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
