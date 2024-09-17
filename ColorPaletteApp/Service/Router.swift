import Foundation

typealias Success  = (_ response: URLResponse?, _ data: Data?) -> Void
typealias Failure = (_ error: Error?) -> Void

protocol NetworkRouter {
    associatedtype EndPoint: EndpointType
    func request(route: EndPoint,
                 success: @escaping Success,
                 failure: @escaping Failure)
}

class Router<EndPoint: EndpointType>: NetworkRouter {
    private var task: URLSessionTask?

    func request(route: EndPoint,
                 success: @escaping Success,
                 failure: @escaping Failure) {
        
        let session = URLSession.shared
        do {
            let request = try buildRequest(from: route)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                guard
                    let response = response as? HTTPURLResponse,
                    response.statusCode >= 200 && response.statusCode <= 300 else {
                    failure(error)
                    return
                }
                success(response, data)
            })
        } catch {
            failure(error)
        }
        task?.resume()
    }


    func perform(task: @escaping (_ success: @escaping Success, _ failure: @escaping Failure) -> Void,
                 success: @escaping (URLResponse?, Data?) -> Void,
                 failure: @escaping (Error?) -> Void) {

        task({response, data in
            success(response, data)
        },
        { error in
            print("Failed: \(String(describing: error))")
            failure(error)
        })
    }
    
    private func buildRequest(from route: EndPoint) throws -> URLRequest {
        
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 15.0)//3.0)
        
        request.httpMethod = route.httpMethod.rawValue
        switch route.task {
        case .request:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        case .requestParameters(let bodyParameters,
                                let bodyEncoding,
                                let urlParameters):

            try configureParameters(bodyParameters: bodyParameters,
                                    bodyEncoding: bodyEncoding,
                                    urlParameters: urlParameters,
                                    request: &request)

        case .requestParametersAndHeaders(let bodyParameters,
                                          let bodyEncoding,
                                          let urlParameters,
                                          let additionalHeaders):

            addAdditionalHeaders(additionalHeaders, request: &request)
            try configureParameters(bodyParameters: bodyParameters,
                                    bodyEncoding: bodyEncoding,
                                    urlParameters: urlParameters,
                                    request: &request)
        }
        return request
    }
    
    private func configureParameters(bodyParameters: Parameters?,
                                     bodyEncoding: ParameterEncoding,
                                     urlParameters: Parameters?,
                                     request: inout URLRequest) throws {

        try bodyEncoding.encode(urlRequest: &request,
                                bodyParameters: bodyParameters, urlParameters: urlParameters)
    }
    
    private func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}
