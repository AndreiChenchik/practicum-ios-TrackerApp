import UIKit

final class WrapperCollectionCell: UICollectionViewCell {
    var wrappedView: UIView?

    func configure(view: UIView?) {
        if let wrappedView {
            wrappedView.removeConstraints(wrappedView.constraints)
            self.wrappedView = nil
        }

        if let view {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)

            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }

    override func prepareForReuse() {
        configure(view: nil)
    }
}
