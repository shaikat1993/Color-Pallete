//
//  AddColorCell.swift
//  ColorPaletteApp
//
//  Created by Md Sadidur Rahman on 17/9/24.
//

import UIKit

class AddColorCell: UICollectionViewCell {
    static let id = "AddColorCell"
    public var addColorButtonAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func addColorBtnPressed(_ sender: Any) {
        addColorButtonAction?()
    }
}
