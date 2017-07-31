//
//  VariationTableViewCell.swift
//  SwiggyTest
//
//  Created by Kushagra Gupta on 29/07/17.
//  Copyright © 2017 Kushagra Gupta. All rights reserved.
//

import UIKit

class VariationTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vegImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var inStockLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpCell(_ variation:Variation){
        nameLabel.text = variation.name
        priceLabel.text = "\u{20B9} \(variation.price)"
        if variation.isVeg{
            vegImage.image = UIImage(named: "ic_veg")
        }else{
             vegImage.image = UIImage(named: "ic_non_veg")
        }
        self.accessoryType = variation.isSelected ? .checkmark : .none
        if variation.inStock{
            inStockLabel.text = "In Stock"
        }else{
            inStockLabel.text = "Not in Stock"
        }
    }
    
}
