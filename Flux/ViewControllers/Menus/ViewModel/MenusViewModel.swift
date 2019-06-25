import Foundation
import WordPressFlux

class MenusViewModel<Service: RemoteService>: Observable {
    enum State {
        case stationary
        case loading
        case completed
    }

    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    var menus: [Menu] {
        return store.getMenus()
    }
    
    private var getMenusReceipt: Receipt?
    private var storeReceipt: Receipt?
    private let store: MenusStore<Service>
    private (set) var state: State = .stationary {
        didSet {
            self.emitChange()
        }
    }
    
    init(service: Service) {
        store = MenusStore(service: service)
        storeReceipt = store.onStateChange { [weak self] (_, state) in
            self?.state = state.isOperating() ? .loading : .completed
        }
    }
    
    func fetchMenus() {
        getMenusReceipt = store.query(.getMenus)
    }
    
    func reloadMenus() {
        store.onDispatch(MenusStoreAction.getMenus)
    }
}
