//
//  RecipeCell.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var dishNameTextfield: UILabel!
    @IBOutlet weak var durationTextfield: UILabel!
    @IBOutlet weak var dishImageview: UIImageView!

    var detailAction : ((UITableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func detailsAction(_ sender: Any) {
        detailAction?(self)
    }
}
