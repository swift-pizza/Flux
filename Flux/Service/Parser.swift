import Foundation

final class Parser {
    typealias ParserCompletion<T: Decodable> = (Result<T, ServiceError>) -> Void
    
    static func parse<T: Decodable>(with data: Data, completion: ParserCompletion<T>) {
        let decoder = JSONDecoder()
        
        do {
            let parsedData = try decoder.decode(T.self, from: data)
            completion(.success(parsedData))
        } catch {
            completion(.failure(.custom(title: "Mapping Model Error", description: error.localizedDescription, code: 0)))
        }
    }
}
