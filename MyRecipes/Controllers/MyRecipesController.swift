//
//  MyRecipesController.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import UIKit

class MyRecipesController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var recipeTypeButton: UIButton!
    @IBOutlet weak var recipesTableView: UITableView!
    
    var customPickerObj     : CustomPicker!
    var selectedPickerItem  : String?
    
    var recipesTypes    : [RecipesTypesModel] = []
    var recipeTitle     = String()
    var recipeTitleID   = String()
    var elementName     = String()
    
    var arrAllRecipes : [AllRecipesModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "My Recipes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(navigationAddAction))
        
        recipesTableView.tableFooterView = UIView()
        
        if let path = Bundle.main.url(forResource: "RecipeTypes", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Read Recipes available in Core Data
        readDefaultRecipes()
    }
    
    // MARK: - Initial Methods
    @objc func navigationAddAction() {
        
        let viewRecipeInfoVC = AppUtility.getUserStoryboardInstance().instantiateViewController(withIdentifier: "ViewRecipeInfoID") as! AddViewEditRecipeController
        viewRecipeInfoVC.viewRecipeDishName = ""
        viewRecipeInfoVC.recipesTypes = self.recipesTypes
        viewRecipeInfoVC.screenMode = .ADD
        
        self.navigationController?.pushViewController(viewRecipeInfoVC, animated: true)
    }
    
    func readDefaultRecipes() {
        arrAllRecipes = CoreDataReadQueries.readAllRecipes()
        if arrAllRecipes.isEmpty {
            insertDefaultRecipes()
            return
        }
        
        //
        selectedPickerItem = recipesTypes[0].title
        
        // show all recipes in table
        print("RECIPES COUNT FROM TABLE: ", arrAllRecipes.count)
        
        recipesTableView .reloadData()
    }
    
    func insertDefaultRecipes() {
        
        let arrBreakfast = ["French Toast", "Nasi Lemak", "Roti Canai"]
        for recipe in arrBreakfast {
            let dictInputs: Dictionary<String, Any> = [
                "foodTypeID" : recipesTypes[1].titleID,
                "foodTypeName" : recipesTypes[1].title,
                "dishName" : recipe,
                "duration"  : "5 mins",
                "howToCook" : "<Add steps to cook>",
                "ingredients" : "<Add recipe ingredients>"
            ]
            
            CommonManagedObject.insertValuesToCoreData(entityName: .TBL_ALL_RECIPES, dictInputs: dictInputs)
        }
        
        let arrLunch = ["Rice with Chicken Curry", "Beef Tail soup", "Mutton Briyani"]
        for recipe in arrLunch {
            let dictInputs: Dictionary<String, Any> = [
                "foodTypeID" : recipesTypes[2].titleID,
                "foodTypeName" : recipesTypes[2].title,
                "dishName" : recipe,
                "duration"  : "10 mins",
                "howToCook" : "<Add steps to cook>",
                "ingredients" : "<Add recipe ingredients>"
            ]
            
            CommonManagedObject.insertValuesToCoreData(entityName: .TBL_ALL_RECIPES, dictInputs: dictInputs)
        }
        
        
        let arrDessets = ["Brownie Cake", "Strawberry smootie", "Vanilla Berry Ice cream"]
        for recipe in arrDessets {
            let dictInputs: Dictionary<String, Any> = [
                "foodTypeID" : recipesTypes[3].titleID,
                "foodTypeName" : recipesTypes[3].title,
                "dishName" : recipe,
                "duration"  : "8 mins",
                "howToCook" : "<Add steps to cook>",
                "ingredients" : "<Add recipe ingredients>"
            ]
            
            CommonManagedObject.insertValuesToCoreData(entityName: .TBL_ALL_RECIPES, dictInputs: dictInputs)
        }
        
        let arrBeverages = ["Teh o Limau", "Nescafe", "Lime Cocktail"]
        for recipe in arrBeverages {
            let dictInputs: Dictionary<String, Any> = [
                "foodTypeID" : recipesTypes[4].titleID,
                "foodTypeName" : recipesTypes[4].title,
                "dishName" : recipe,
                "duration"  : "3 mins",
                "howToCook" : "<Add steps to cook>",
                "ingredients" : "<Add recipe ingredients>"
            ]
            
            CommonManagedObject.insertValuesToCoreData(entityName: .TBL_ALL_RECIPES, dictInputs: dictInputs)
        }
        
        // Read inserted recipes from table
        readDefaultRecipes()
    }
    
    // MARK: - Button Action
    
    @IBAction func filterRecipesTypes(_ sender: Any) {
        createCustomPickerInstance()
        
        addCustomPicker()
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

// MARK: - Extension
extension MyRecipesController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if recipesTypes.count == 0 { return 0 }
        
        // selected type of recipes
        if selectedPickerItem != recipesTypes[0].title {
            // not equal to "All"
            // then show only selected type of recipes
            return 1
        }
        
        // All recipes
        return recipesTypes.count-1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // selected type of recipes
        if selectedPickerItem != recipesTypes[0].title {
            return selectedPickerItem
        }
        
        // All recipes
        return recipesTypes[section+1].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recipesTypes.count == 0 { return 0 }
        
        // selected type of recipes
        if selectedPickerItem != recipesTypes[0].title {
            var countRecipesUnderType = 0
            for recipe in arrAllRecipes {
                if recipe.foodTypeName == selectedPickerItem {
                    countRecipesUnderType += 1
                }
            }
            return countRecipesUnderType
        }
        
        // All recipes
        var countRecipesUnderType = 0
        for recipe in arrAllRecipes {
            if recipe.foodTypeID == recipesTypes[section+1].titleID {
                countRecipesUnderType += 1
            }
        }
        
        return countRecipesUnderType
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCellID", for: indexPath) as! RecipeCell
        
        var recipesByTypes : [AllRecipesModel] = []
        
        if selectedPickerItem != recipesTypes[0].title {
            // selected type of recipes
            for recipe in arrAllRecipes {
                if recipe.foodTypeName == selectedPickerItem {
                    recipesByTypes.append(recipe)
                }
            }
        }
        else {
            // All recipes
            for recipe in arrAllRecipes {
                if recipe.foodTypeID == recipesTypes[indexPath.section+1].titleID {
                    recipesByTypes.append(recipe)
                }
            }
        }
        
        // show recipes
        for (index, recipe) in recipesByTypes.enumerated() {
            if index == indexPath.row {
                cell.dishNameTextfield.text = recipe.dishName
                cell.durationTextfield.text = recipe.duration
            }
        }
        
        cell.detailAction = { (tapped) in
            let viewRecipeInfoVC = AppUtility.getUserStoryboardInstance().instantiateViewController(withIdentifier: "ViewRecipeInfoID") as! AddViewEditRecipeController
            viewRecipeInfoVC.viewRecipeDishName = cell.dishNameTextfield.text ?? ""
            viewRecipeInfoVC.recipesTypes = self.recipesTypes
            
            self.navigationController?.pushViewController(viewRecipeInfoVC, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension MyRecipesController : CustomPickerDelegate {
    func itemPicked(item: AnyObject) {
        if let pickedItem = item as? String {
            selectedPickerItem = pickedItem
            
            self.recipeTypeButton.setTitle(pickedItem, for: .normal)
            print("SELECTED PICKER ITEM: ", selectedPickerItem ?? "NA")
        }
        removeCustomPicker()
        
        recipesTableView .reloadData()
    }
    
    func pickerCancelled()
    {
        removeCustomPicker()
        selectedPickerItem = ""
    }
}

extension MyRecipesController : XMLParserDelegate {
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("1")
        
        if elementName == "type" {
            recipeTitle = ""
            recipeTitleID = ""
        }
        
        self.elementName = elementName
        print("Element: ", self.elementName);
    }
    
    // 2
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("2")
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!data.isEmpty) {
            if self.elementName == "titleID" {
                recipeTitleID = data
                print("titleID: ", self.recipeTitleID);
            }
            else if self.elementName == "title" {
                recipeTitle = data
                print("title: ", self.recipeTitle);
            }
        }
    }
    
    // 3
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("3")
        
        if elementName == "type" {
            let recipesType = RecipesTypesModel(title: recipeTitle, titleID: recipeTitleID)
            recipesTypes.append(recipesType)
            print("Extracted Recipes Types: ", recipesTypes);
        }
    }
}

