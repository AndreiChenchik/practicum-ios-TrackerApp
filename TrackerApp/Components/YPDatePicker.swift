import UIKit

final class YPDatePicker: UIDatePicker {
    private var kvObservers: Set<NSKeyValueObservation> = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        changeDatePickerAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YPDatePicker {
    private func changeDatePickerAppearance() {
        self
            .subViewsWhere { view in
                guard let backgroundColor = view.backgroundColor else { return false }
                return backgroundColor.cgColor.alpha != 1
            }
            .forEach { view in
                view.backgroundColor = .asset(.datePickerBackground)

                kvObservers.insert(
                    view.observe(\.backgroundColor) { [weak view] _, _ in
                        guard let view, let backgroundColor = view.backgroundColor else { return }

                        if backgroundColor != .asset(.datePickerBackground) {
                            view.backgroundColor = .asset(.datePickerBackground)
                        }
                    }
                )
            }

        self
            .subViewsWhere { view in
                view is UILabel
            }
            .forEach { view in
                guard let label = view as? UILabel else { return }
                label.tintColor = .asset(.blackUniversal)
                label.textColor = .asset(.blackUniversal)
                label.font = .asset(.ysDisplayRegular, size: 17)

                kvObservers.insert(
                    label.observe(\.textColor) { [weak label] _, _ in
                        guard let label, let textColor = label.textColor else { return }

                        if textColor != .asset(.blackUniversal) {
                            label.textColor = .asset(.blackUniversal)
                        }
                    }
                )
            }
    }
}
