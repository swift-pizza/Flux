import Foundation
import WordPressFlux

typealias MenuType = Menu.MenuType

enum MenusStoreAction: Action {
    case getMenus
    case deleteMenu(type: Menu.MenuType)
}

enum MenusStoreQuery {
    case getMenus
    case deleteMenu(type: Menu.MenuType)
}

struct MenusStoreState {
    var menus: [Menu] = []
    var fetchingMenus: Bool = false
    
    var deletingMenu = Set<MenuType>()
    
    func isOperating() -> Bool {
        return fetchingMenus ||
            !deletingMenu.isEmpty
    }
}

class MenusStore<Service: RemoteService>: QueryStore<MenusStoreState, MenusStoreQuery> {
    private weak var service: Service?
    
    init(service: Service) {
        self.service = service
        super.init(initialState: MenusStoreState())
    }
    
    override func onDispatch(_ action: Action) {
        guard let action = action as? MenusStoreAction else {
            return
        }
        
        switch action {
        case .getMenus:
            fetchMenus()
        case .deleteMenu(let type):
            deleteMenu(for: type)
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
            case .deleteMenu(let type):
                deleteMenu(for: type)
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
}

private extension MenusStore {
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
}
