//
//  ProductTableViewCell.swift
//  MyShopping
//
//  Created by Sami Rämö on 14/06/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!

    let colorTheme = AppColors.Theme1()
    
    var productName: String? {
        didSet { updateUI() }
    }
    
    private func updateUI() {
        productNameLabel.text = productName
    }
    
    var cellColor: UIColor {
        get {
            return cellBackgroundView.backgroundColor!
        } set {
            cellBackgroundView.backgroundColor = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellBackgroundView.layer.cornerRadius = 5.0
        contentView.backgroundColor = colorTheme.lightBackgroundColor
        selectionStyle = .none
    }
    
}
