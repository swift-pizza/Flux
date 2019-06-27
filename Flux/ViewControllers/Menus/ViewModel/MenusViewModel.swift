import Foundation
import WordPressFlux

class MenusViewModel<Service: RemoteService>: Observable {
    enum State {
        case stationary
        case loading
        case completed(error: ServiceError?)
    }

    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    var menus: [Menu] {
        return store.getMenus()
    }
    
    private var getMenusReceipt: Receipt?
    private var storeReceipt: Receipt?
    private let store: PizzeriaStore<Service>
    private (set) var state: State = .stationary {
        didSet {
            self.emitChange()
        }
    }
    
    init(service: Service) {
        store = PizzeriaStore(service: service)
        storeReceipt = store.onChange { [weak self] in
            self?.updateState()
        }
    }
    
    func fetchMenus() {
        getMenusReceipt = store.query(.getMenus)
    }
    
    func reloadMenus() {
        store.onDispatch(PizzeriaStoreAction.reloadMenus)
    }
}

private extension MenusViewModel {
    func updateState() {
        switch store.fetchingMenusStatus() {
        case .stationary:
            state = .stationary
        case .fetching:
            state = .loading
        case .fetchingCompleted(let error):
            state = .completed(error: error)
        }
    }
}
