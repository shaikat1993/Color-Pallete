//
//  ColorStorage.swift
//  ColorPaletteApp
//
//  Created by Md Sadidur Rahman on 17/9/24.
//

import Foundation

class ColorStorage {
    private enum StorageKeys: String {
        case favoriteColors = "favoriteColors"
    }
    
    static let shared = ColorStorage()
    
    private init() { }
    
    func saveFavoriteColor(_ color: String) {
        var favoriteColors = getFavoriteColors()
        favoriteColors.append(color)
        UserDefaults.standard.set(favoriteColors, forKey: StorageKeys.favoriteColors.rawValue)
    }
    
    func getFavoriteColors() -> [String] {
        return UserDefaults.standard.stringArray(forKey: StorageKeys.favoriteColors.rawValue) ?? []
    }
    
    func removeFavoriteColor(_ color: String) {
        var favoriteColors = getFavoriteColors()
        favoriteColors.removeAll { $0 == color }
        UserDefaults.standard.set(favoriteColors, forKey: StorageKeys.favoriteColors.rawValue)
    }
}
