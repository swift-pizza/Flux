import Foundation
import WordPressFlux

typealias MenuType = Menu.MenuType

enum PizzeriaStoreAction: Action {
    case reloadMenus
    case deleteMenu(type: MenuType)
    case reloadPizzas(type: MenuType)
}

enum PizzeriaStoreQuery {
    case getMenus
    case getPizzas(type: MenuType)
}

struct PizzeriaStoreState {
    var menus: [Menu] = []
    var fetchingMenus: Bool = false
    var deletingMenu = Set<MenuType>()
    
    var pizzas: [MenuType: [Pizza]] = [:]
    var fetchingPizzas: [MenuType: Bool] = [:]
    
    func isOperatingMenu() -> Bool {
        return fetchingMenus ||
            !deletingMenu.isEmpty
    }
    
    func isOperatingPizzas() -> Bool{
        return fetchingPizzas.first { $0.value }?.value ?? false
    }
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
        case .deleteMenu(let type):
            deleteMenu(for: type)
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
    
    func isFetchingMenus() -> Bool {
        return state.fetchingMenus
    }
    
    func isDeletingMenu(for type: MenuType) -> Bool {
        return state.deletingMenu.contains(type)
    }
    
    func isFetchingPizzas(for type: MenuType) -> Bool {
        return state.fetchingPizzas[type] ?? false
    }
}

private extension PizzeriaStore {
    func fetchMenus() {
        if state.fetchingMenus {
            return
        }
        
        transaction {
            $0.fetchingMenus = true
        }
        
        service?.execute(.menus) { [weak self] (result: Result<Pizzeria, ServiceError>) in
            DispatchQueue.main.async {
                self?.transaction {
                    $0.fetchingMenus = false
                    $0.menus = result.getSuccess()?.menus ?? []
                }
            }
        }
    }
    
    func deleteMenu(for type: MenuType) {
        if isDeletingMenu(for: type) {
            return
        }

        transaction {
            $0.deletingMenu.insert(type)
        }
    }
    
    func fetchPizzas(for type: MenuType) {
        if isFetchingPizzas(for: type) {
            return
        }
        
        transaction {
            $0.fetchingPizzas[type] = true
        }
        
        service?.execute(.menu(type)) { [weak self] (result: Result<[Pizza], ServiceError>) in
            DispatchQueue.main.async {
                self?.transaction {
                    $0.fetchingPizzas[type] = false
                    $0.pizzas[type] = result.getSuccess() ?? []
                }
            }
        }
    }
}
