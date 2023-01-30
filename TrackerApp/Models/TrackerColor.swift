import UIKit

enum TrackerColor: String, Hashable, CaseIterable {
    case red = "#FD4C49"
    case lightOrange = "#FF881E"
    case blue = "#007BFA"
    case purple = "#6E44FE"
    case green = "#33CF69"
    case lightPurple = "#E66DD4"
    case lightPink = "#F9D4D4"
    case lightBlue = "#34A7FE"
    case lightGreen = "#46E69D"
    case indigo = "#35347C"
    case orange = "#FF674D"
    case pink = "#FF99CC"
    case paleOrange = "#F6C48B"
    case paleBlue = "#7994F5"
    case brightPurple = "#832CF1"
    case paleIndigo = "#AD56DA"
    case palePurple = "#8D72E6"
    case brightGreen = "#2FD058"
}

extension TrackerColor {
    var uiColor: UIColor { .init(hex: self.rawValue + "ff") ?? .asset(.blue) }
}
