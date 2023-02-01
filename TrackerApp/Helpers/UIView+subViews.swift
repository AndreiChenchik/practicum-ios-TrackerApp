import UIKit

extension UIView {
    func subViewsWhere(_ filter: (UIView) -> Bool) -> [UIView] {
        subviews.filter(filter) + subviews.flatMap { $0.subViewsWhere(filter) }
    }
}
