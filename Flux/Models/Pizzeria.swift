import Foundation

struct Menu: Codable {
    enum MenuType: String, Codable {
        case classic
        case white
        case light
        case special
    }

    var type: MenuType
    var title: String
}

struct Pizzeria: Codable {
    var menus: [Menu]
}
