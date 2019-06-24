import Foundation
import WordPressFlux

class InfoViewModel<Service: RemoteService>: Observable {
    enum State {
        case stationary
        case loading
        case completed(Bool)
    }

    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    var sections: [InfoSection] {
        return store.getSections()
    }

    private var storeReceipt: Receipt?
    private let store: InfoStore<Service>
    private (set) var state: State = .stationary {
        didSet {
            self.emitChange()
        }
    }
    
    init(service: Service) {
        store = InfoStore(service: service)
        storeReceipt = store.onStateChange { [weak self] (_, nextState) in
            switch nextState.status {
            case .stationary:
                self?.state = .stationary
            case .fetching:
                self?.state = .loading
            case .fetchingCompleted(let error):
                self?.state = .completed(error == nil)
            }
        }
    }
    
    func fetchInfo() {
        store.onDispatch(InfoStoreAction.fetch)
    }
}
