import Foundation
import WordPressFlux

class InfoViewModel: Observable {
    var changeDispatcher: Dispatcher<Void> = Dispatcher()
    
    enum State {
        case stationary
        case loading
        case completed(Bool, [InfoSection])
    }
    
    private let service = PizzeriaService()
    private (set) var state: State = .stationary {
        didSet {
            emitChange()
        }
    }
    
    func start() {
        state = .loading
        service.execute(.info) { [weak self] (result: Result<About, ServiceError>) in
            switch result {
            case .failure:
                self?.state = .completed(false, [])
            case .success(let me):
                self?.state = .completed(true, me.sections)
            }
        }
    }
}
