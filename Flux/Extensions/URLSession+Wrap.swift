import Foundation

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
