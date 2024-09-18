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

    // Save a favorite color
    func saveFavoriteColor(_ color: Color) {
        var favoriteColors = getFavoriteColors()
        favoriteColors.append(color)
        if let data = try? JSONEncoder().encode(favoriteColors) {
            UserDefaults.standard.set(data, forKey: StorageKeys.favoriteColors.rawValue)
        }
    }

    // Get the list of favorite colors
    func getFavoriteColors() -> [Color] {
        guard let savedData = UserDefaults.standard.data(forKey: StorageKeys.favoriteColors.rawValue),
              let favoriteColors = try? JSONDecoder().decode([Color].self, from: savedData) else {
            return []
        }
        return favoriteColors
    }

    // Remove a favorite color by its id
    func removeFavoriteColor(_ color: Color) {
        var favoriteColors = getFavoriteColors()
        favoriteColors.removeAll { $0.id == color.id }
        if let data = try? JSONEncoder().encode(favoriteColors) {
            UserDefaults.standard.set(data, forKey: StorageKeys.favoriteColors.rawValue)
        }
    }
    
    // Update an existing favorite color by its id
    func updateFavoriteColor(_ updatedColor: Color) {
        var favoriteColors = getFavoriteColors()
        if let index = favoriteColors.firstIndex(where: { $0.id == updatedColor.id }) {
            favoriteColors[index] = updatedColor
        } else {
            print("Color with id \(updatedColor.id) not found.")
            return
        }
        
        if let data = try? JSONEncoder().encode(favoriteColors) {
            UserDefaults.standard.set(data, forKey: StorageKeys.favoriteColors.rawValue)
        }
    }
}
