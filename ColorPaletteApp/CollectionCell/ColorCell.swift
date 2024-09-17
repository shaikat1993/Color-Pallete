//
//  ColorCell.swift
//  ColorPaletteApp
//
//  Created by Md Sadidur Rahman on 17/9/24.
//

import UIKit

class ColorCell: UICollectionViewCell {
    static let id = "ColorCell"
    
    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
}
