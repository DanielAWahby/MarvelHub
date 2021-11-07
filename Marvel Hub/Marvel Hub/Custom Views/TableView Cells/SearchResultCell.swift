//
//  SearchResultCell.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var characterNameLabel:UILabel!
    @IBOutlet weak var characterImage:UIImageView!
    var passedSearchText = ""
    var passedSubstring = ""
    var shouldHighlightResult = false {
        didSet{
            if shouldHighlightResult{
                highlightResult(passedSearchText,passedSubstring)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func highlightResult(_ searchText:String,_ substringText:String){
       
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 10, left:20, bottom: 0, right: 20)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}
