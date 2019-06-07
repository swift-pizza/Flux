import Foundation

enum Request {
    case menus
    case menu(Menu.MenuType)
    
    var jsonName: String {
        switch self {
        case .menu(let type):
            return "\(type.rawValue)_menu.json"
        case .menus:
            return "pizzeria_menus.json"
        }
    }
}


class PizzeriaService {
    private let baseURLString = "https://github.com/swift-pizza/Flux/blob/master/JSON/"

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
}
