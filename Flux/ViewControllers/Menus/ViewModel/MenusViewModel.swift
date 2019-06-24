import Foundation
import WordPressFlux

class MenusViewModel<Service: RemoteService>: Observable {
    enum State {
        case stationary
        case loading
        case completed(Bool)
    }

    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    var menus: [Menu] {
        return []
    }
    
    private var storeReceipt: Receipt?
    private (set) var state: State = .stationary {
        didSet {
            self.emitChange()
        }
    }
    
    init(service: Service) {
        
    }
    
    func fetchMenus() {
        
    }
}
