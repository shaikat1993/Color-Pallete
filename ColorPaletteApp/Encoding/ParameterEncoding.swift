import Foundation

typealias Parameters = [String: Any]

protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

enum ParameterEncoding {
    
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    
    func encode(urlRequest: inout URLRequest,
                       bodyParameters: Parameters?,
                       urlParameters: Parameters?) throws {
        switch self {
        case .urlEncoding:
            guard let urlParameters = urlParameters else { return }
            try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)

        case .jsonEncoding:
            guard let bodyParameters = bodyParameters else { return }
            try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)

        case .urlAndJsonEncoding:
            guard let bodyParameters = bodyParameters,
                  let urlParameters = urlParameters else { return }
            try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
            try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
        }
    }
}


enum NetworkError: String, Error {
    case missingURL = "URL is nil."
}
