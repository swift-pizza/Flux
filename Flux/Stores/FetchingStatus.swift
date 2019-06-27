import Foundation

enum FetchingStatus: Equatable {
    case stationary
    case fetching
    case fetchingCompleted(error: ServiceError?)
    
    static func == (lhs: FetchingStatus, rhs: FetchingStatus) -> Bool {
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

    func isFetching() -> Bool {
        return self == .fetching
    }
}