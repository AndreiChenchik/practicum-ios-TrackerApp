import UIKit

enum ColorAsset: String, CaseIterable {
    case black, blue, white, gray, red
    case contrast, background
}

extension UIColor {
    static func asset(_ colorAsset: ColorAsset) -> UIColor {
        UIColor(named: colorAsset.rawValue) ?? .clear
    }
}
