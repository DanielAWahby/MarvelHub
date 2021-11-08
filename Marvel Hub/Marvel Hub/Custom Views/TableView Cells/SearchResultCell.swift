//
//  SearchResultCell.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

// MARK:- Search Controller's Table View Cell

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var characterNameLabel:UILabel!
    @IBOutlet weak var characterImage:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
// MARK:- Padding for the Search Result View Cell
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 10, left:20, bottom: 0, right: 20)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}
