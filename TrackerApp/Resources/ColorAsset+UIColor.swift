import UIKit

enum ColorAsset: String, CaseIterable {
    case black, blue, white, gray, lightGray, red, blackUniversal
    case contrast, background
    case statisticsGradient1, statisticsGradient2, statisticsGradient3
}

extension UIColor {
    static func asset(_ colorAsset: ColorAsset) -> UIColor {
        UIColor(named: colorAsset.rawValue) ?? .clear
    }
}
