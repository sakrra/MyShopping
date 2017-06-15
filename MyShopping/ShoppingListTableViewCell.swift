//
//  ShoppingListTableViewCell.swift
//  MyShopping
//
//  Created by Sami Rämö on 11/05/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var itemCountLabel: UILabel!
    
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
        cellBackgroundView.layer.cornerRadius = cellBackgroundView.frame.height / 4
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //if selected {
        //    cellColor = UIColor.cellSelectColor
        //    //selectedBackgroundView?.backgroundColor = UIColor.black
        //    //backgroundView?.backgroundColor = UIColor.black
        //} else {
        //    cellBackgroundView.backgroundColor = cellColor
        //}
    }

}
