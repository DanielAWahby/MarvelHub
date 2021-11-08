//
//  CharacterViewCell.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 30/10/2021.
//

import UIKit

// MARK:- All Characters Controller's Table View Cell

class CharacterViewCell: UITableViewCell {
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

// MARK:- Padding for the Character View Cell
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}
