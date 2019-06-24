import Foundation
import WordPressFlux

enum InfoStoreAction: Action {
    case fetch
}

struct InfoStoreState {
    var status: StoreStatus = .stationary
    var sections: [InfoSection] = []
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
    
    func getSections() -> [InfoSection] {
        return state.sections
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
                    state.sections = result.getSuccess()?.sections ?? []
                    state.status = .fetchingCompleted(error: result.getError())
                }
            }
        }
    }
}

extension Result where Failure == ServiceError {
    func getSuccess() -> Success? {
        switch self {
        case .failure:
            return nil
        case .success(let value):
            return value
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
