//
//  CoreDataReadQueries.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import Foundation
import CoreData
import UIKit

// SELECT Query
class CoreDataReadQueries: NSObject {
    
    static func readAllRowsFrom(entityName : CORE_DATA_ENTITIES) -> Array<Any> {
        guard let sharedAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let moContext : NSManagedObjectContext = sharedAppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.name)
        
        do {
            let results = try moContext.fetch(fetchRequest)
            return results
        } catch {
            print("Fetch result failed")
        }
        
        return []
    }
    
    static func readAllRecipes() -> [AllRecipesModel] {

        let arrResults = CoreDataReadQueries.readAllRowsFrom(entityName: .TBL_ALL_RECIPES)
        
        var allRecipesModel : [AllRecipesModel] = []
        for data in arrResults as! [NSManagedObject] {
            let dishName        = data.value(forKey: "dishName") as? String ?? ""
            let duration        = data.value(forKey: "duration") as? String ?? ""
            let foodTypeID      = data.value(forKey: "foodTypeID") as? String ?? ""
            let foodTypeName    = data.value(forKey: "foodTypeName") as? String ?? ""
            let howToCook       = data.value(forKey: "howToCook") as? String ?? ""
            let ingredients     = data.value(forKey: "ingredients") as? String ?? ""

            let dictFoUserData : Dictionary<String, Any> = [
                "dishName" : dishName,
                "duration" : duration,
                "foodTypeID" : foodTypeID,
                "foodTypeName" : foodTypeName,
                "howToCook" : howToCook,
                "ingredients" : ingredients,

            ] as [String : Any]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dictFoUserData, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                
                // CaseFo
                let model = try JSONDecoder().decode(AllRecipesModel.self, from: jsonData)
                allRecipesModel.append(model)
            } catch let error {
                print("ERROR WHEN DECODE: ", error)
                return []
            }
        }
        
        return allRecipesModel
    }
    
    static func readRecipeFor(dishName: String) -> [AllRecipesModel] {
        guard let sharedAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let moContext : NSManagedObjectContext = sharedAppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CORE_DATA_ENTITIES.TBL_ALL_RECIPES.name)
        fetchRequest.predicate = NSPredicate(format: "dishName = %i", argumentArray: [dishName])

        do {
            let results = try moContext.fetch(fetchRequest)
            
            var allRecipesModel : [AllRecipesModel] = []
            for data in results as! [NSManagedObject] {
                let dishName        = data.value(forKey: "dishName") as? String ?? ""
                let duration        = data.value(forKey: "duration") as? String ?? ""
                let foodTypeID      = data.value(forKey: "foodTypeID") as? String ?? ""
                let foodTypeName    = data.value(forKey: "foodTypeName") as? String ?? ""
                let howToCook       = data.value(forKey: "howToCook") as? String ?? ""
                let ingredients     = data.value(forKey: "ingredients") as? String ?? ""

                let dictFoUserData : Dictionary<String, Any> = [
                    "dishName" : dishName,
                    "duration" : duration,
                    "foodTypeID" : foodTypeID,
                    "foodTypeName" : foodTypeName,
                    "howToCook" : howToCook,
                    "ingredients" : ingredients,

                ] as [String : Any]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dictFoUserData, options: .prettyPrinted)
                    // here "jsonData" is the dictionary encoded in JSON data
                    
                    // CaseFo
                    let model = try JSONDecoder().decode(AllRecipesModel.self, from: jsonData)
                    allRecipesModel.append(model)
                } catch let error {
                    print("ERROR WHEN DECODE: ", error)
                    return []
                }
            }
            
            return allRecipesModel // even array it should return one item only
        } catch {
            print("Fetch result failed")
        }
        
        return []
    }
}
