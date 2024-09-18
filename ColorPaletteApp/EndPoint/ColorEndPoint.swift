import Foundation
import UIKit

enum ColorAPI {
    case login(username: String, password: String)
    case create(color: String)
    case update(id: String, color: String)
    case getColor(id: String)
    case delete(id: String)
}

extension ColorAPI: EndpointType {
    private static let username = ""
    private static let password = ""

    var baseURL: URL {
        guard let url = URL(string: "https://llz939pjhg.execute-api.eu-west-1.amazonaws.com/api/v1") else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .create( _):
            return "storage"
        case .update(let id, _):
            return "storage/\(id)"
        case .getColor(let id):
            return "storage/\(id)"
        case .delete(id: let id):
            return "storage/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login,
             .create:
            return .post
        case .update:
            return .put
        case .getColor:
            return .get
        case .delete:
            return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let username, let password):
            return .requestParameters(bodyParameters: ["username": username,//ColorAPI.username,
                                                       "password": password], //ColorAPI.password],
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
            
        case .create(let color), 
             .update(_, let color):
            let  username = UserDefaultsManager.shared.storedUsername
            guard let token = KeychainHelper.shared.getToken(for: username) else {
                return .requestParametersAndHeaders(bodyParameters: nil,
                                                    bodyEncoding: .jsonEncoding,
                                                    urlParameters: nil,
                                                    additionHeaders: ["Authorization": ""])
            }
            
            let bodyParameters = ["data": color]
            return .requestParametersAndHeaders(bodyParameters: bodyParameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: ["Authorization": token])
//        case .create(let color):
//            return  .requestParametersAndHeaders(bodyParameters: ["data": color],
//                                                 bodyEncoding: .jsonEncoding,
//                                                 urlParameters: nil,
//                                                 additionHeaders: ["Authorization" : TokenHandler.currentToken() ?? ""])
//        case .update( _, let color):
//            return  .requestParametersAndHeaders(bodyParameters: ["data": color],
//                                                 bodyEncoding: .jsonEncoding,
//                                                 urlParameters: nil,
//                                                 additionHeaders: ["Authorization" : TokenHandler.currentToken() ?? ""])
        case .delete(id: _):
            return  .requestParametersAndHeaders(bodyParameters: nil,
                                                 bodyEncoding: .jsonEncoding,
                                                 urlParameters: nil,
                                                 additionHeaders: ["Authorization": TokenHandler.currentToken(for: UserDefaultsManager.shared.storedUsername) ?? ""])
        default:
            return  .requestParametersAndHeaders(bodyParameters: nil,
                                                 bodyEncoding: .jsonEncoding,
                                                 urlParameters: nil,
                                                 additionHeaders: ["Authorization": TokenHandler.currentToken(for: UserDefaultsManager.shared.storedUsername) ?? ""])
            
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }

}

//struct TokenHandler {
//    static func save(_ token: String) {
//        // TODO: This is probably not a good place for this
//        //UserDefaults.standard.setValue(token, forKey: "auth_token")
//        KeychainHelper.shared.saveToken(token, for: UserDefaultsManager.shared.storedUsername)
//
//    }
//
//    static func currentToken() -> String? {
//       // return UserDefaults.standard.string(forKey: "auth_token")
//        return KeychainHelper.shared.getToken(for: UserDefaultsManager.shared.storedUsername)
//
//    }
//}


struct TokenHandler {
    static func save(_ token: String, for username: String) {
        KeychainHelper.shared.saveToken(token, for: username)
    }

    static func currentToken(for username: String) -> String? {
        return KeychainHelper.shared.getToken(for: username)
    }
}
