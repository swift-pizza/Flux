import Foundation

enum Request {
    case menus
    case menu(Menu.MenuType)
    
    var jsonName: String {
        switch self {
        case .menu(let type):
            return "\(type.rawValue)_menu.json"
        case .menus:
            return "pizzeria_menus.json"
        }
    }
}


enum ServiceError: Error {
    case general
    case custom(title: String?, description: String?, code: Int)
}

class PizzeriaService {
    private let baseURLString = "http://bogodaniele.com/pizza-swift/01/"

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
    
    func execute(_ request: Request, _ completion: @escaping (Result<Pizzeria, ServiceError>) -> Void) {
        let fullURL = baseURLString + request.jsonName
        guard let url = URL(string: fullURL) else {
            completion(.failure(ServiceError.general))
            return
        }
        
        let task = session.dataTask(request: URLRequest(url: url), completionHandler: { (data, urlResponse, error) in
            if let error = error {
                completion(.failure(.custom(title: "Task Error", description: error.localizedDescription, code: 0)))
            } else if let data = data {
                let resultData: Result<Data, ServiceError> = .success(data)
                Parser.parse(with: resultData) { (result: Result<Pizzeria, ServiceError>) in
                    completion(result)
                }
            }
        })
        task.resume()
    }
}

protocol URLSessionProtocol {
    func dataTask(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}


extension URLSession: URLSessionProtocol {
    func dataTask(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        #if DEBUG
        print("----------")
        print("Requesting (\(request.httpMethod ?? "??"))", request.url?.absoluteString ?? "no url", separator: " ")
        
        if let headers = request.allHTTPHeaderFields {
            print("Request headers:")
            print(headers.map { "\($0) : \($1)" }.joined(separator: "\n"))
        }
        print("----------")
        #endif
        
        return self.dataTask(with: request, completionHandler: completionHandler)
    }
}

final class Parser {
    typealias ParserCompletion<T: Decodable> = (Result<T, ServiceError>) -> Void

    static func parse<T: Decodable>(with data: Result<Data, ServiceError>, completion: ParserCompletion<T>) {
        switch data {
        case .failure(let error):
            completion(.failure(error))

        case .success(let data):
            let decoder = JSONDecoder()

            do {
                let parsedData = try decoder.decode(T.self, from: data)
                completion(.success(parsedData))
            } catch {
                completion(.failure(.custom(title: "Mapping Model Error", description: error.localizedDescription, code: 0)))
            }
        }
    }
}
