//
//  RecipeInfoCell.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import UIKit

class RecipeInfoCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var dishNameTextfield    : UITextField!
    @IBOutlet weak var durationTextfield    : UITextField!
    @IBOutlet weak var ingredientsTextview  : UITextView!
    @IBOutlet weak var howToCookTextview    : UITextView!
    @IBOutlet weak var foodTypeButton       : UIButton!
    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var dishPicture          : UIImageView!
    
    var addPicAction: ((UITableViewCell) -> Void)?
    var showPickerAction: ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addPicTapped(_ sender: Any) {
        addPicAction?(self)
    }
    
    @IBAction func showPickerTapped(_ sender: Any) {
        showPickerAction?(self)
    }

}
