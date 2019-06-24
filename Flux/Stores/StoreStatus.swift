import Foundation

enum StoreStatus: Equatable {
    case stationary
    case fetching
    case fetchingCompleted(error: ServiceError?)
    
    static func == (lhs: StoreStatus, rhs: StoreStatus) -> Bool {
        switch (lhs, rhs) {
        case (.stationary, .stationary):
            return true
        case (.fetching, .fetching):
            return true
        case (.fetchingCompleted, .fetchingCompleted):
            return true
        default:
            return false
        }
    }
}
