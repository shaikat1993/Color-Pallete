import Foundation
import UIKit

enum NetworkResponse: String {
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

struct NetworkManager {
    
    let router = Router<ColorAPI>()
    
    typealias LoginCompletionHandler = (_ token: String?, _ error: String?) -> Void
    typealias ColorCompletionHandler = (_ color: Color?, _ error: String?) -> Void
    typealias DeleteCompletionHandler = (_ success: Bool, _ error: String?) -> Void
    
    // MARK: - LOGIN

    /// Performs our POC login action and returns Authorisation token, that can be used for other API calls.
    func login(username: String, password: String, completion: @escaping LoginCompletionHandler) {
        router.perform(task: { success, failure in
                        self.router.request(route: .login(username: username, 
                                                          password: password),
                                            success: success,
                                            failure: failure) },
                       success: { response, data in
                        guard let responseData = data else {
                            completion(nil, NetworkResponse.noData.rawValue)
                            return
                        }
                        do {
                            let apiResponse = try JSONDecoder().decode(Login.self, from: responseData)
                            completion(apiResponse.token, nil)
                        } catch {
                            print(error)
                            completion(nil, NetworkResponse.unableToDecode.rawValue)
                        }
                       },
                       failure: { error in
                        completion(nil, error.debugDescription)
                       })
    }
    
    // MARK: - GET COLOR

    /// Checks the API for any data that is saved with the given `Id`. Returns the data object or `nil` if there is no data.
    func getColorWithId(_ id: String, completion: @escaping ColorCompletionHandler)  {
        router.perform(task: { success, failure in
                        self.router.request(route: .getColor(id: id),
                                            success: success, failure: failure) },
                       success: { response, data in
                        self.parseData(data: data, response: response, completion: completion)
                        
                       },
                       failure: { error in
                        completion(nil, error.debugDescription)
                       })
    }

    // MARK: - CREATE COLOR

    /// Sends the `Color` data to the server.
    /// If successful, the server responds with the sent `Color` and associated id.
    /// The `id` can be used to fetch the same color `getColorWithId:completion:` or to update it `updateColorForId:color:completion`.
    func create(color: String, completion: @escaping ColorCompletionHandler) {
        func executeUpdate(attempts: Int) {
            // Stop retrying if no attempts are left
            guard attempts > 0 else {
                completion(nil, "Max retry attempts reached.")
                return
            }
            router.perform(task: { success, failure in
                self.router.request(route: .create(color: color),
                                    success: success, failure: failure) },
                           success: { response, data in
                self.parseData(data: data, response: response, completion: completion)
                
            },
                           failure: { error in
                print("Request failed, retrying... Attempts left: \(attempts - 1)")
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    executeUpdate(attempts: attempts - 1)
                }
                completion(nil, error.debugDescription)
            })
        }
        // Start the request with 3 attempts
        executeUpdate(attempts: 3)
    }
    
    // MARK: - UPDATE COLOR

    /// Updates the existing `Color` data to the server.
    /// The server responds with the sent `Color` and associated id, that can be used to fetch the same color. (`getColorWithId:completion:`)
    func updateColorForId(_ id: String, color: String, completion: @escaping ColorCompletionHandler) {
        func executeUpdate(attempts: Int) {
            // Stop retrying if no attempts are left
            guard attempts > 0 else {
                completion(nil, "Max retry attempts reached.")
                return
            }
            router.perform(task: { success, failure in
                self.router.request(route: .update(id: id, color: color),
                                    success: success, failure: failure) },
                           success: { response, data in
                self.parseData(data: data, response: response, completion: completion)
                
            },
                           failure: { error in
                print("Request failed, retrying... Attempts left: \(attempts - 1)")
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    executeUpdate(attempts: attempts - 1)
                }
                completion(nil, error.debugDescription)
            })
        }
        // Start the request with 3 attempts
        executeUpdate(attempts: 3)
    }
    
    /// Deletes the `Color` with the given `Id` from the server.
    func deleteColorWithId(_ id: String, completion: @escaping DeleteCompletionHandler) {
        func executeUpdate(attempts: Int) {
            // Stop retrying if no attempts are left
            guard attempts > 0 else {
                completion(false, "Max retry attempts reached.")
                return
            }
            router.perform(task: { success, failure in
                self.router.request(route: .delete(id: id),
                                    success: success, failure: failure) },
                           success: { response, data in
                // Handle the success response here. Depending on the API, it might return some data or just a success message.
                completion(true, nil)
            },
                           failure: { error in
                print("Request failed, retrying... Attempts left: \(attempts - 1)")
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    executeUpdate(attempts: attempts - 1)
                }
                completion(false, error.debugDescription)
            })
        }
        // Start the request with 3 attempts
        executeUpdate(attempts: 3)
    }
    
    // MARK: - Private

//    private func parseData(data: Data?, response: URLResponse?, completion: ColorCompletionHandler)  {
//        guard let responseData = data else {
//            completion(nil, NetworkResponse.noData.rawValue)
//            return
//        }
////        if let jsonString = String(data: responseData, encoding: .utf8) {
////               print("Received JSON: \(jsonString)")
////           } else {
////               print("Failed to convert data to string.")
////           }
//           
//        // Attempt to decode the data into a Color object
//           do {
//               let apiResponse = try JSONDecoder().decode(Color.self, from: responseData)
//               completion(apiResponse, nil)
//           } catch {
//               print("Decoding error: \(error)")
//               completion(nil, NetworkResponse.unableToDecode.rawValue)
//           }
//        
////        do {
//////            let r = String(data: data ?? Data(), encoding: .utf8)
//////            print(r)
////            
////            let apiResponse = try JSONDecoder().decode(Color.self, from: responseData)
////            completion(apiResponse, nil)
////        }
////        catch {
////            print(error)
////            completion(nil, NetworkResponse.unableToDecode.rawValue)
////        }
//    }
    
    
    private func parseData(data: Data?, response: URLResponse?, completion: ColorCompletionHandler) {
        guard let responseData = data else {
            completion(nil, NetworkResponse.noData.rawValue)
            return
        }

        do {
            // Decode the JSON response into the `Color` model
            let apiResponse = try JSONDecoder().decode(Color.self, from: responseData)
            
            // Convert the `data` string into an array of `CGFloat`
            if let colorArray = parseColorData(apiResponse.data) {
                // Assuming you need to create a `Color` instance to return to the completion
                completion(Color(data: apiResponse.data,
                                 id: apiResponse.id),
                           nil)
                // Here, you can also set your `UIColor` using the `colorArray`
//                let color = UIColor(rgba: colorArray)
//                print("Color created: \(color)")
                
            } else {
                completion(nil, NetworkResponse.unableToDecode.rawValue)
            }
        } catch {
            print("Decoding error: \(error)")
            completion(nil, NetworkResponse.unableToDecode.rawValue)
        }
    }

    func parseColorData(_ dataString: String) -> [CGFloat]? {
        // Attempt to decode the string as a JSON array of CGFloats
        guard let data = dataString.data(using: .utf8) else { return nil }
        
        do {
            let colorArray = try JSONDecoder().decode([CGFloat].self, from: data)
            return colorArray
        } catch {
            print("Failed to parse color data: \(error)")
            return nil
        }
    }
}
