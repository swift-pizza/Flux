import Foundation
import WordPressFlux

class InfoViewModel<Service: RemoteService>: Observable {
    enum State {
        case stationary
        case loading
        case completed(Bool, [InfoSection])
    }

    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    
    private var storeReceipt: Receipt?
    private let store: InfoStore<Service>
    private (set) var state: State = .stationary {
        didSet {
            DispatchQueue.main.async {
                self.emitChange()
            }
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
            case .fetchingCompleted(let sections, let error):
                self?.state = .completed(error == nil, sections)
            }
        }
    }
    
    func fetchInfo() {
        store.onDispatch(InfoStoreAction.fetch)
    }
}
