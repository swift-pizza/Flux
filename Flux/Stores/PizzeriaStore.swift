import Foundation
import WordPressFlux

typealias MenuType = Menu.MenuType

enum PizzeriaStoreAction: Action {
    case reloadMenus
    case reloadPizzas(type: MenuType)
}

enum PizzeriaStoreQuery {
    case getMenus
    case getPizzas(type: MenuType)
}

struct PizzeriaStoreState {
    var menus: [Menu] = []
    var fetchingMenus: FetchingStatus = .stationary

    var pizzas: [MenuType: [Pizza]] = [:]
    var fetchingPizzas: [MenuType: FetchingStatus] = [:]
}

class PizzeriaStore<Service: RemoteService>: QueryStore<PizzeriaStoreState, PizzeriaStoreQuery> {
    private weak var service: Service?
    
    init(service: Service) {
        self.service = service
        super.init(initialState: PizzeriaStoreState())
    }
    
    override func onDispatch(_ action: Action) {
        guard let action = action as? PizzeriaStoreAction else {
            return
        }
        
        switch action {
        case .reloadMenus:
            fetchMenus()
        case .reloadPizzas(let type):
            fetchPizzas(for: type)
        }
    }
    
    override func queriesChanged() {
        super.queriesChanged()
        
        if activeQueries.isEmpty {
            return
        }
        
        activeQueries.forEach { query in
            switch query {
            case .getMenus:
                fetchMenus()
            case .getPizzas(let type):
                fetchPizzas(for: type)
            }
        }
    }
    
    func getMenus() -> [Menu] {
        return state.menus
    }
    
    func fetchingMenusStatus() -> FetchingStatus {
        return state.fetchingMenus
    }
    
    func fetchingPizzasStatus(for type: MenuType) -> FetchingStatus {
        return state.fetchingPizzas[type] ?? .stationary
    }
}

private extension PizzeriaStore {
    func fetchMenus() {
        if fetchingMenusStatus().isFetching() {
            return
        }
        
        transaction {
            $0.fetchingMenus = .fetching
        }
        
        service?.execute(.menus) { [weak self] (result: Result<Pizzeria, ServiceError>) in
            DispatchQueue.main.async {
                self?.transaction {
                    $0.fetchingMenus = .fetchingCompleted(error: result.getError())
                    $0.menus = result.getSuccess()?.menus ?? []
                }
            }
        }
    }
    
    func fetchPizzas(for type: MenuType) {
        if fetchingPizzasStatus(for: type).isFetching() {
            return
        }
        
        transaction {
            $0.fetchingPizzas[type] = .fetching
        }
        
        service?.execute(.menu(type)) { [weak self] (result: Result<[Pizza], ServiceError>) in
            DispatchQueue.main.async {
                self?.transaction {
                    $0.fetchingPizzas[type] = .fetchingCompleted(error: result.getError())
                    $0.pizzas[type] = result.getSuccess() ?? []
                }
            }
        }
    }
}
