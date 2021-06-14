//
//  CommonManagedObject.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import UIKit
import CoreData

enum CORE_DATA_ENTITIES : CaseIterable {
    // ?: Is it hold case equipment needed?
    case TBL_ALL_RECIPES
    public var name: String {
        switch self {
        case .TBL_ALL_RECIPES: return "AllRecipes"
        }
    }
}

class CommonManagedObject: NSObject {
    
    // INSERT Query
    static func insertValuesToCoreData(entityName : CORE_DATA_ENTITIES, dictInputs : Dictionary<String, Any>) {
        print("Insert data to \(entityName) table - started ==")
        
        guard let sharedAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let moContext : NSManagedObjectContext = sharedAppDelegate.persistentContainer.viewContext
        let entity  = NSEntityDescription.entity(forEntityName: entityName.name, in: moContext)
        let mObject = NSManagedObject(entity: entity!, insertInto: moContext)
        
        switch entityName {
        case .TBL_ALL_RECIPES:
            mObject.setValue(dictInputs["foodTypeID"], forKey: "foodTypeID")
            mObject.setValue(dictInputs["foodTypeName"], forKey: "foodTypeName")
            mObject.setValue(dictInputs["dishName"], forKey: "dishName")
            mObject.setValue(dictInputs["duration"], forKey: "duration")
            mObject.setValue(dictInputs["howToCook"], forKey: "howToCook")
            mObject.setValue(dictInputs["ingredients"], forKey: "ingredients")
        }
        
        self.saveContext(moContext: moContext, entityName: entityName)
    }
    
    // UPDATE Query
    static func updateValuesToCoreData(entityName : CORE_DATA_ENTITIES, currentValue1: String,  dictUpdatedValues : Dictionary<String, Any>) {
        guard let sharedAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let moContext : NSManagedObjectContext = sharedAppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.name)
        
        switch entityName {
        
        case .TBL_ALL_RECIPES:
            print("TBL_ALL_RECIPES - updating values")
            
            fetchRequest.predicate = NSPredicate(format: "dishName = %i", argumentArray: [currentValue1])
            do {
                let results = try moContext.fetch(fetchRequest) as? [NSManagedObject] ?? []
                
                for data in results {
                    
                    if dictUpdatedValues.keys.contains("dishName") {
                        data.setValue(dictUpdatedValues["dishName"], forKey: "dishName")
                    }
                    
                    if dictUpdatedValues.keys.contains("duration") {
                        data.setValue(dictUpdatedValues["duration"], forKey: "duration")
                    }
                    
                    if dictUpdatedValues.keys.contains("howToCook") {
                        data.setValue(dictUpdatedValues["howToCook"], forKey: "howToCook")
                    }
                    
                    if dictUpdatedValues.keys.contains("ingredients") {
                        data.setValue(dictUpdatedValues["ingredients"], forKey: "ingredients")
                    }
                    
                    if dictUpdatedValues.keys.contains("foodTypeID") {
                        data.setValue(dictUpdatedValues["foodTypeID"], forKey: "foodTypeID")
                    }
                    
                    if dictUpdatedValues.keys.contains("foodTypeName") {
                        data.setValue(dictUpdatedValues["foodTypeName"], forKey: "foodTypeName")
                    }
                    
                    // Update more keys or columns if you want
                }
            } catch {
                print("Fetch Failed: \(error)")
            }
        }
        
        self.saveContext(moContext: moContext, entityName: entityName)
    }
    
    // DELETE Query
    static func deleteAllDataInTable(entityName : CORE_DATA_ENTITIES) {
        guard let sharedAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let moContext : NSManagedObjectContext = sharedAppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.name)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try moContext.execute(deleteRequest)
        } catch {
            print ("There was an error")
        }
        self.saveContext(moContext: moContext, entityName: entityName)
    }
    
    static func deleteSpecificRowsInTable(entityName : CORE_DATA_ENTITIES, value1: String, value2: String = "") {
        guard let sharedAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let moContext : NSManagedObjectContext = sharedAppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.name)
        
        switch entityName {
        case .TBL_ALL_RECIPES:
            let predicate1 = NSPredicate(format: "dishName == %@", value1)
            if value2 != "" {
                let predicate2 = NSPredicate(format: "dishName == %@", value2)
                let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2])
                fetchRequest.predicate = predicateCompound
            } else {
                fetchRequest.predicate = predicate1
            }
        }
        
        // Now, delete
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try moContext.execute(deleteRequest)
        } catch {
            print ("deleteSpecificRowInTable - There was an error")
        }
        self.saveContext(moContext: moContext, entityName: entityName)
    }
    
    static func saveContext(moContext : NSManagedObjectContext, entityName : CORE_DATA_ENTITIES) {
        do {
            print("Context saved!!!")
            try moContext.save()
            
            // NO NEED TO CALL PRINT METHOD HERE
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    // Optional: For developer convenient - log purpose
    static func printDataFromGiven(entityName : CORE_DATA_ENTITIES) {
        print("================== Print - \(entityName) Values ===")
        
        guard let sharedAppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let moContext : NSManagedObjectContext = sharedAppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.name)
        
        switch entityName {
        case .TBL_ALL_RECIPES:
            do {
                let result = try moContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    print("dishName == \(data.value(forKey: "dishName") ?? "")")
                    print("foodTypeID == \(data.value(forKey: "foodTypeID") ?? "")")
                    print("foodTypeName == \(data.value(forKey: "foodTypeName") ?? "")")
                    print("duration == \(data.value(forKey: "duration") ?? "")")
                    print("howToCook == \(data.value(forKey: "howToCook") ?? "")")
                    print("ingredients == \(data.value(forKey: "ingredients") ?? "")")

                    print("============= ROW END ===")
                }
            } catch {
                print("Fetch result failed")
            }
        }
    }
}
