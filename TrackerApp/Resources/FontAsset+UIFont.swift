import UIKit

enum FontAsset: String, CaseIterable {
    case ysDisplayBold = "YSDisplay-Bold"
    case ysDisplayMedium = "YSDisplay-Medium"
    case ysDisplayRegular = "YandexSansDisplay-Regular"
}

extension UIFont {
    static func asset(_ fontAsset: FontAsset, size: CGFloat) -> UIFont {
        let fallback = UIFont.systemFont(ofSize: size)
        let assetFont = UIFont(name: fontAsset.rawValue, size: size)

        return assetFont ?? fallback
    }
}
