import UIKit

struct TrackerColor: Hashable {
    let hex: String
}

extension TrackerColor {
    var uiColor: UIColor { .init(hex: hex + "ff") ?? .black }
}
