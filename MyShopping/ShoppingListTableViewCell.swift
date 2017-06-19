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
    
    @IBOutlet weak var strikeImageView: UIImageView!
    
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
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
        strikeImageView.backgroundColor = colorTheme.strikeColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /*let newFrame = cellBackgroundView.frame
        print("newFrame \(newFrame)")
        print("cellBackgroundView.bounds \(cellBackgroundView.bounds)")
        strikethroughView.frame = CGRect(x: StrikethroughConstants.spacing, y: (newFrame.height-StrikethroughConstants.height)/2, width: newFrame.width-(4*StrikethroughConstants.spacing), height: StrikethroughConstants.height)
        print("cellBackgroundView.frame \(cellBackgroundView.frame)")
        print("strikethroughView.frame \(strikethroughView.frame)")*/
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
