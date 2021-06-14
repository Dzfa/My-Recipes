//
//  ViewRecipeInfoController.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import UIKit

enum SCREEN_MODE {
    case ADD, VIEW, EDIT, NONE
}

class AddViewEditRecipeController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var viewRecipeInfoTableview: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var bottomConstraintOfTableView: NSLayoutConstraint!
    
    
    var viewRecipeDishName = "" // value comes from prev screen
    var recipesTypes : [RecipesTypesModel] = [] // value comes from prev screen
    
    var customPickerObj         : CustomPicker!
    var selectedRecipeType      : String?
    var selectedRecipeTypeID    : String?
    
    var viewRecipeModel : AllRecipesModel?
    
    var updatedDishName     : String?
    var updatedDuration     : String?
    var updatedHowToCook    : String?
    var updatedIngredients  : String?
    var updatedFoodType     : String?
    
    var imageOfRecipe : UIImage?
    
    var screenMode = SCREEN_MODE.VIEW
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: screenMode == .ADD ? "Add" : "Edit", style: .plain, target: self, action: #selector(editTapped))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        viewRecipeInfoTableview.canCancelContentTouches = true
        viewRecipeInfoTableview.addGestureRecognizer(tapGesture)
        
        self.viewRecipeInfoTableview.tableFooterView = UIView()
        
        deleteButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if recipesTypes.count >= 1 {
            recipesTypes.removeFirst() // remove "all" option
        }
        
        if screenMode == .ADD {
            selectedRecipeType = recipesTypes[0].title
            selectedRecipeTypeID = recipesTypes[1].titleID
            
            updatedDishName     = ""
            updatedDuration     = ""
            updatedHowToCook    = ""
            updatedIngredients  = ""
            updatedFoodType     = ""
            
            viewRecipeInfoTableview .reloadData()
            
            deleteButton.isHidden = true
            bottomConstraintOfTableView.constant = 0
        } else {
            deleteButton.isHidden = false
            bottomConstraintOfTableView.constant = 100
            readRecipeInfoFromDB()
        }
    }
    
    // MARK: - Initial Methods
    @objc func hideKeyboard() {
        viewRecipeInfoTableview.endEditing(true)
        
        viewRecipeInfoTableview .reloadData()
    }
    
    // MARK: Add / Modify Recipe
    @objc func editTapped() {
        if screenMode == .VIEW {
            screenMode = .EDIT
            navigationItem.rightBarButtonItem?.title = "Save"
            
            readRecipeInfoFromDB()
        } else if screenMode == .EDIT {
            screenMode = .VIEW
            navigationItem.rightBarButtonItem?.title = "Edit"
            
            // Update table
            
            updateRecipeInfoInDB()
        } else if screenMode == .ADD {
            let status = validateWhenAddRecipe()
            if !status.isSuccess {
                AppUtility.showSuccessFailureAlert(title: IDENTIFIERS.WARNING, message: status.message, controller: self)
                return
            }
            
            // Insert recipe in table
            insertNewRecipeInDB()
            
            AppUtility.showSuccessFailureAlertWithDismissHandler(title: IDENTIFIERS.SUCCESS, message: "Recipe has been added successfully.", controller: self) { (done) in
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        viewRecipeInfoTableview .reloadData()
    }
    
    func readRecipeInfoFromDB() {
        // using dishname
        let recipeInfo = CoreDataReadQueries.readRecipeFor(dishName: viewRecipeDishName)
        if recipeInfo.count >= 1 {
            viewRecipeModel = recipeInfo[0]
            print("DISH NAME FRoM MODEL: ", viewRecipeModel?.dishName ?? "")
            
            updatedDishName = viewRecipeModel?.dishName ?? ""
            updatedDuration = viewRecipeModel?.duration ?? ""
            updatedHowToCook = viewRecipeModel?.howToCook ?? ""
            updatedIngredients = viewRecipeModel?.ingredients ?? ""
            selectedRecipeType = viewRecipeModel?.foodTypeName ?? ""
            selectedRecipeTypeID = viewRecipeModel?.foodTypeID ?? ""
            
            viewRecipeInfoTableview .reloadData()
        }
    }
    
    func updateRecipeInfoInDB() {
        
        let dictInputs: Dictionary<String, Any> = [
            "foodTypeID" : selectedRecipeTypeID ?? (viewRecipeModel?.foodTypeID ?? ""),
            "foodTypeName" : selectedRecipeType ?? (viewRecipeModel?.foodTypeName ?? ""),
            "dishName" : updatedDishName ?? "",
            "duration"  : updatedDuration ?? "",
            "howToCook" : updatedHowToCook ?? "",
            "ingredients" : updatedIngredients ?? ""
        ]
        
        CommonManagedObject.updateValuesToCoreData(entityName: .TBL_ALL_RECIPES, currentValue1: viewRecipeDishName, dictUpdatedValues: dictInputs)
        
        // now change
        viewRecipeDishName = updatedDishName ?? ""
    }
    
    func validateWhenAddRecipe() -> (isSuccess: Bool, message: String) {
        var isSuccess = true
        var message = ""
        
        if updatedDishName == "" {
            isSuccess = false
            message = "Please enter the dish name"
        } else if updatedDuration == "" {
            isSuccess = false
            message = "Please enter the duration to prepare recipe"
        } else if updatedHowToCook == "" {
            isSuccess = false
            message = "Please give some info about how to cook this recipe"
        } else if updatedIngredients == "" {
            isSuccess = false
            message = "Please enter needed ingredients for this recipe"
        }
        
        return (isSuccess, message)
    }
    
    func insertNewRecipeInDB() {
        let dictInputs: Dictionary<String, Any> = [
            "foodTypeID" : selectedRecipeTypeID ?? recipesTypes[0].titleID,
            "foodTypeName" : selectedRecipeType ?? recipesTypes[0].title,
            "dishName" : updatedDishName ?? "",
            "duration"  : updatedDuration ?? "",
            "howToCook" : updatedHowToCook ?? "",
            "ingredients" : updatedIngredients ?? ""
        ]
        
        CommonManagedObject.insertValuesToCoreData(entityName: .TBL_ALL_RECIPES, dictInputs: dictInputs)
    }
    
    // MARK: - Button Action
    
    @IBAction func deleteAction(_ sender: Any) {
        
        AppUtility.showAlertWithOptionsAndDismissHandler(title: "Confirm", message: "Are you sure want to delete this recipe?", postiveOption: "Cancel", negativeOption: "Delete", controller: self) { (cancel) in
            
        } alertDismissedWithNeg: { (delete) in
            CommonManagedObject.deleteSpecificRowsInTable(entityName: .TBL_ALL_RECIPES, value1: self.viewRecipeDishName)
            
            AppUtility.showSuccessFailureAlertWithDismissHandler(title: IDENTIFIERS.SUCCESS, message: "Recipe has been deleted successfully.", controller: self) { (done) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Custom Picker
    func createCustomPickerInstance()
    {
        customPickerObj = AppUtility.getCustomPickerInstance()
        customPickerObj.delegate = self
        customPickerObj.totalComponents = 1
                
        var titles : [String] = []
        for type in recipesTypes {
            titles.append(type.title)
        }
        customPickerObj.arrayComponent = titles
    }
    
    func addCustomPicker() {
        self.view.addSubview(customPickerObj.view)
        
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_String)
    }
    
    func removeCustomPicker()
    {
        if customPickerObj != nil
        {
            customPickerObj.view.removeFromSuperview()
        }
    }
}

extension AddViewEditRecipeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screenMode == .ADD ? 1 : (viewRecipeModel != nil ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeInfoCellID", for: indexPath) as! RecipeInfoCell
        
        cell.dishNameTextfield.delegate = self
        cell.durationTextfield.delegate = self
        cell.dishNameTextfield.layer.masksToBounds = true
        cell.durationTextfield.layer.masksToBounds = true
        cell.dishNameTextfield.layer.addBorder(edge: .bottom, color: .darkGray, thickness: 0.5)
        cell.durationTextfield.layer.addBorder(edge: .bottom, color: .darkGray, thickness: 0.5)
        
        if self.screenMode == .VIEW {
            cell.dishNameTextfield.isUserInteractionEnabled = false
            cell.durationTextfield.isUserInteractionEnabled = false
            cell.howToCookTextview.isUserInteractionEnabled = false
            cell.ingredientsTextview.isUserInteractionEnabled = false
            cell.foodTypeButton.isUserInteractionEnabled = false
            cell.addPictureButton.isUserInteractionEnabled = false
            cell.foodTypeButton.isHidden = true
            cell.addPictureButton.isHidden = true
            
        } else if self.screenMode == .EDIT || self.screenMode == .ADD {
            cell.dishNameTextfield.isUserInteractionEnabled = true
            cell.durationTextfield.isUserInteractionEnabled = true
            cell.howToCookTextview.isUserInteractionEnabled = true
            cell.ingredientsTextview.isUserInteractionEnabled = true
            cell.foodTypeButton.isUserInteractionEnabled = true
            cell.addPictureButton.isUserInteractionEnabled = true
            cell.foodTypeButton.isHidden = false
            cell.addPictureButton.isHidden = false
            
            updatedDuration = cell.durationTextfield.text ?? ""
            updatedDishName = cell.dishNameTextfield.text ?? ""
            updatedHowToCook = cell.howToCookTextview.text ?? ""
            updatedIngredients = cell.ingredientsTextview.text ?? ""
            
            cell.showPickerAction = { (tapped) in
                self.view.endEditing(true)
                
                self.createCustomPickerInstance()
                
                self.addCustomPicker()
            }
        }
        
        cell.addPicAction = { (tapped) in
            if self.screenMode == .EDIT || self.screenMode == .ADD {
                self.showAlert()
            }
        }
        
        cell.dishNameTextfield.text = updatedDishName
        cell.durationTextfield.text = updatedDuration
        cell.howToCookTextview.text = updatedHowToCook
        cell.ingredientsTextview.text = updatedIngredients
        cell.foodTypeButton.setTitle(selectedRecipeType, for: .normal)
        
        if let image = imageOfRecipe {
            cell.dishPicture.image = image
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 650
    }
}

extension AddViewEditRecipeController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        viewRecipeInfoTableview .reloadData()
        
        return true
    }
}

extension AddViewEditRecipeController : UITextViewDelegate {
    
}


extension AddViewEditRecipeController : CustomPickerDelegate {
    func itemPicked(item: AnyObject) {
        if let pickedItem = item as? String {
            selectedRecipeType = pickedItem
            print("SELECTED PICKER ITEM: ", selectedRecipeType ?? "")
            
            for type in recipesTypes {
                if type.title == selectedRecipeType {
                    selectedRecipeTypeID = type.titleID
                }
            }
        }
        removeCustomPicker()
        
        viewRecipeInfoTableview .reloadData()
    }
    
    func pickerCancelled()
    {
        removeCustomPicker()
    }
}

//MARK:- Image Picker
extension AddViewEditRecipeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Show alert to selected the media source type.
    private func showAlert() {

        let alert = UIAlertController(title: "Image Selection", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {

        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    //MARK:- UIImagePickerViewDelegate.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true) { [weak self] in

            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            //Setting image to your image view
            self?.imageOfRecipe = image
            
            self?.viewRecipeInfoTableview .reloadData()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
