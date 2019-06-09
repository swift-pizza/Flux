import Foundation

enum Request {
    case menus
    case menu(Menu.MenuType)
    case info
    
    var jsonName: String {
        switch self {
        case .menu(let type):
            return "\(type.rawValue)_menu.json"
        case .menus:
            return "pizzeria_menus.json"
        case .info:
            return "info.json"
        }
    }
}

enum ServiceError: Error {
    case general
    case custom(title: String?, description: String?, code: Int)
}

class PizzeriaService {
    typealias PizzeriaServiceCompletion<T: Decodable> = (Result<T, ServiceError>) -> Void

    enum Environment {
        case local
        case production(String)
    }

    private let environment: Environment
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
    
    init(_ environment: Environment = .local) {
        self.environment = environment
    }

    func execute<T: Codable>(_ request: Request, _ completion: @escaping PizzeriaServiceCompletion<T>) {
        switch environment {
        case .local:
            execute(request, completion: completion)
        case .production(let baseURL):
            execute((request: request, baseURLString: baseURL), completion)
        }
    }
}

private extension PizzeriaService {
    func execute<T: Codable>(_ remote:(request: Request, baseURLString: String), _ completion: @escaping PizzeriaServiceCompletion<T>) {
        let fullURLString = remote.baseURLString + remote.request.jsonName
        guard let url = URL(string: fullURLString) else {
            completion(.failure(ServiceError.general))
            return
        }
        
        let task = session.dataTask(request: URLRequest(url: url), completionHandler: { (data, urlResponse, error) in
            if let data = data {
                Parser.parse(with: data) { (result: Result<T, ServiceError>) in
                    completion(result)
                }
            } else {
                completion(.failure(.custom(title: "Task Error", description: error?.localizedDescription ?? "no description", code: 0)))
            }
        })
        task.resume()
    }
    
    func execute<T: Codable>(_ request: Request, completion: @escaping PizzeriaServiceCompletion<T>) {
        do {
            if let file = Bundle.main.url(forResource: request.jsonName, withExtension: nil) {
                let data = try Data(contentsOf: file)
                Parser.parse(with: data) { (result: Result<T, ServiceError>) in
                    completion(result)
                }
            } else {
                completion(.failure(.custom(title: "Error", description: "Mapping error", code: 0)))
            }
        } catch {
            completion(.failure(.custom(title: "Error", description: error.localizedDescription, code: 0)))
        }
    }
}
