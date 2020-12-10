//
//  WebSection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

struct WebSection {
    var name: String = ""
    var ingredients: [WebIngredient] = []
    
    init(name: String, ingredients: [WebIngredient]) {
        self.name = name
        self.ingredients = ingredients
    }
    
    init() {}
}
