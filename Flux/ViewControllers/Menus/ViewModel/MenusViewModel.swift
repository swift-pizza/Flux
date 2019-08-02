import Foundation
import WordPressFlux

class MenusViewModel<Service: RemoteService>: Observable {
    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    var menus: [Menu] {
        return store.getMenus()
    }
    
    private var getMenusReceipt: Receipt?
    private var storeReceipt: Receipt?
    private let store: PizzeriaStore<Service>
    private (set) var state: FetchingStatus = .idle {
        didSet {
            self.emitChange()
        }
    }
    
    init(store: PizzeriaStore<Service>) {
        self.store = store
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
        state = store.fetchingMenusStatus()
    }
}
