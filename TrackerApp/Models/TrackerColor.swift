import UIKit

struct TrackerColor {
    let hex: String
}

extension TrackerColor {
    var uiColor: UIColor { .init(hex: hex + "ff") ?? .black }
}
