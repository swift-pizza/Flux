import Foundation
import WordPressFlux

enum InfoStoreAction: Action {
    case fetch
}

struct InfoStoreState {
    enum Status: Equatable {
        case stationary
        case fetching
        case fetchingCompleted(sections: [InfoSection], error: ServiceError?)
        
        static func == (lhs: InfoStoreState.Status, rhs: InfoStoreState.Status) -> Bool {
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
    
    var status: Status = .stationary
}

class InfoStore<Service: RemoteService>: StatefulStore<InfoStoreState> {
    private weak var service: Service?

    init(service: Service) {
        self.service = service
        super.init(initialState: InfoStoreState())
    }
    
    override func onDispatch(_ action: Action) {
        guard let action = action as? InfoStoreAction else {
            return
        }

        switch action {
        case .fetch:
            fetchInfo()
        }
    }
}

private extension InfoStore {
    func fetchInfo() {
        if state.status == .fetching {
            return
        }
        
        transaction { state in
            state.status = .fetching
        }

        service?.execute(.info) { [weak self] (result: Result<About, ServiceError>) in
            DispatchQueue.main.async {
                self?.transaction { state in
                    state.status = .fetchingCompleted(sections: result.getSection(),
                                                      error: result.getError())
                }
            }
        }
    }
}

fileprivate extension Result where Success == About, Failure == ServiceError {
    func getSection() -> [InfoSection] {
        switch self {
        case .failure:
            return []
        case .success(let me):
            return me.sections
        }
    }
    
    func getError() -> ServiceError? {
        switch self {
        case .failure(let error):
            return error
        case .success:
            return nil
        }
    }
}
