import Foundation

struct Pizzeria: Codable {
    var menus: [Menu]
}

struct Menu: Codable, Hashable {
    enum MenuType: String, Codable {
        case classic
        case white
        case light
        case special
    }

    var type: MenuType
    var title: String
}

struct Pizza: Codable {
    var name: String
    var ingredients: String
}
