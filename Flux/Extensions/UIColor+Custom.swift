import UIKit

extension UIColor {
    enum CustomColor: String {
        case red
        case lightRed
        case yellow
        case darkYellow
    }

    static func customColor(_ color: CustomColor) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
}
