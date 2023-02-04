import QuartzCore

enum CellCorner {
    case all
    case top, bottom
    case left, right
    case topLeft, topRight, bottomLeft, bottomRight

    var cornerMask: CACornerMask {
        switch self {
        case .topLeft:
            return .layerMinXMinYCorner
        case .topRight:
            return .layerMaxXMinYCorner
        case .bottomLeft:
            return .layerMinXMaxYCorner
        case .bottomRight:
            return .layerMaxXMaxYCorner
        case .left:
            return [Self.topLeft.cornerMask, Self.bottomLeft.cornerMask]
        case .right:
            return [Self.topRight.cornerMask, Self.bottomRight.cornerMask]
        case .top:
            return [Self.topLeft.cornerMask, Self.topRight.cornerMask]
        case .bottom:
            return [Self.bottomLeft.cornerMask, Self.bottomRight.cornerMask]
        case .all:
            return [Self.top.cornerMask, Self.bottom.cornerMask]
        }
    }
}

extension Collection where Element == CellCorner {
    var cornerMask: CACornerMask {
        self.reduce(into: []) { $0 = [$0, $1.cornerMask] }
    }
}
