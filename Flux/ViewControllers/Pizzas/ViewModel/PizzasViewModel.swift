import Foundation
import WordPressFlux

class PizzasViewModel<Service: RemoteService>: Observable {
    enum State {
        case stationary
        case loading
        case completed(error: ServiceError?)
    }
    
    let menuType: MenuType
    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    
    private var getPizzasReceipt: Receipt?
    private var storeReceipt: Receipt?
    private let store: PizzeriaStore<Service>
    private (set) var state: State = .stationary {
        didSet {
            self.emitChange()
        }
    }
    
    init(store: PizzeriaStore<Service>, menuType: MenuType) {
        self.store = store
        self.menuType = menuType
        storeReceipt = store.onChange { [weak self] in
            self?.updateState()
        }
    }
    
    func fetchPizzas(for type: MenuType) {
        getPizzasReceipt = store.query(.getPizzas(type: type))
    }
    
    func reloadPizzas(for type: MenuType) {
        store.onDispatch(PizzeriaStoreAction.reloadPizzas(type: type))
    }
    
    func getPizzas(for type: MenuType) -> [Pizza] {
        return store.getPizzas(for: type)
    }
}

private extension PizzasViewModel {
    func updateState() {
        switch store.fetchingPizzasStatus(for: menuType) {
        case .stationary:
            state = .stationary
        case .fetching:
            state = .loading
        case .fetchingCompleted(let error):
            state = .completed(error: error)
        }
    }
}
