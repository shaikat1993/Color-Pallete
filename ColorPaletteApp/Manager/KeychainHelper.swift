//
//  KeychainHelper.swift
//  ColorPaletteApp
//
//  Created by Md Sadidur Rahman on 17/9/24.
//

import Foundation

struct User {
    let userName: String
    let token: String
    // Password shouldn't be stored here; it's for the login process only
}

class KeychainHelper {
    static let shared = KeychainHelper()
    
    // Save token in Keychain
    func saveToken(_ token: String, for userName: String) {
        let data = Data(token.utf8)
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: userName, // Use the username as the key
            kSecValueData: data
        ] as CFDictionary
        
        SecItemDelete(query) // Ensure no duplicates
        SecItemAdd(query, nil)
    }
    
    // Retrieve token from Keychain
    func getToken(for userName: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: userName,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    // Delete token from Keychain
    func deleteToken(for userName: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: userName
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
