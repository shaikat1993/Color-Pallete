//
//  UserDefaultsManager.swift
//  ColorPaletteApp
//
//  Created by Md Sadidur Rahman on 16/9/24.
//

import UIKit

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() { }
    
    private enum UserDefaultsKeys: String {
        case isLoggedIn = "isLoggedIn"
        case storedUsername = "storedUsername"
    }
    
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
            UserDefaults.standard.synchronize() // Force a sync
        }
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
