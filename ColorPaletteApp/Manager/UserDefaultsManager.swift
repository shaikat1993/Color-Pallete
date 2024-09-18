import UIKit

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() { }
    
    private enum UserDefaultsKeys: String {
        case storedUsername = "storedUsername"
    }
    
    var storedUsername: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.storedUsername.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.storedUsername.rawValue)
            UserDefaults.standard.synchronize() // Force a sync
        }
    }
}
