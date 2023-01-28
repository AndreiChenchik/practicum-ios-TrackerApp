import UIKit

enum ImageAsset: String, CaseIterable {
    case practicumLogo
    case onboarding1, onboarding2
}

extension UIImage {
    static func asset(_ imageAsset: ImageAsset) -> UIImage {
        guard let image = UIImage(named: imageAsset.rawValue) else {
            preconditionFailure("Can't find \(imageAsset.rawValue)")
        }

        return image
    }
}