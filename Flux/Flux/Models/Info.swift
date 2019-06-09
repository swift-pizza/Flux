import Foundation

struct Info: Codable {
    var title: String
    var icon: String
    var url: String
}

struct InfoSection: Codable {
    var title: String
    var info: [Info]
}

struct About: Codable {
    var sections: [InfoSection]
}
