//
//  FurnitureCell.swift
//  ARKeaApp
//
//  Created by Rathod on 7/27/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import UIKit

class FurnitureCell: UITableViewCell {
    
    @IBOutlet weak var vwContainer: UIView! {
        didSet {
            vwContainer.layer.shouldRasterize = true
            vwContainer.layer.rasterizationScale = UIScreen.main.scale
            vwContainer.layer.cornerRadius = 4
            vwContainer.layer.borderWidth = 1
            vwContainer.layer.borderColor = UIColor.gray.cgColor
            //Shadow Setting
            vwContainer.layer.shadowColor = UIColor.black.cgColor
            vwContainer.layer.shadowOpacity = 0.5
            vwContainer.layer.shadowOffset = .zero
            vwContainer.layer.shadowRadius = 4
        }
    }
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var cellType = ""
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
