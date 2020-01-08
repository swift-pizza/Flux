import Foundation
import WordPressFlux

class InfoViewModel<Service: RemoteService>: Observable {
    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    var sections: [InfoSection] {
        return store.getSections()
    }

    private var storeReceipt: Receipt?
    private let store: InfoStore<Service>
    private (set) var state: FetchingStatus = .idle {
        didSet {
            self.emitChange()
        }
    }
    
    init(store: InfoStore<Service>) {
        self.store = store
        storeReceipt = store.onStateChange { [weak self] (_, state) in
            self?.state = state.status
        }
    }
    
    func fetchInfo() {
        store.onDispatch(InfoStoreAction.fetch)
    }
}
