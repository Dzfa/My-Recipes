//
//  AllRecipesModel.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import Foundation

struct AllRecipesModel: Codable {
    let dishName, foodTypeID, foodTypeName, duration, howToCook, ingredients: String
}
