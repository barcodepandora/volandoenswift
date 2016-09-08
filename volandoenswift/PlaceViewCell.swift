//
//  PlaceViewCell.swift
//  volandoenswift
//
//  Created by Juan Manuel Moreno on 7/9/16.
//  Copyright © 2016 uzupis. All rights reserved.
//

import UIKit

class PlaceViewCell: UITableViewCell {

    // Atributos vista cell
    @IBOutlet weak var imgPlace: UIImageView!
    @IBOutlet weak var txtNombre: UILabel!
    @IBOutlet weak var txtDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
