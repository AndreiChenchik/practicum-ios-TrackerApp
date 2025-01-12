import UIKit

enum ImageAsset: String, CaseIterable {
    case practicumLogo
    case onboarding1, onboarding2
    case statisticsTabIcon, trackerTabIcon
    case chevronIcon, checkmarkIcon
    case statsPlaceholder, trackerStartPlaceholder, trackerEmptyPlaceholder
    case addButton
    case pinned
}

extension UIImage {
    static func asset(_ imageAsset: ImageAsset) -> UIImage {
        guard let image = UIImage(named: imageAsset.rawValue) else {
            preconditionFailure("Can't find \(imageAsset.rawValue)")
        }

        return image
    }
}
