import Foundation

enum FetchingStatus: Equatable {
    case idle
    case fetching
    case fetchingCompleted(error: ServiceError?)
}
