//
//  WebRecipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

struct WebRecipe: Identifiable {
    var id: Int
    var name: String = ""
    var imageURL: String = ""
    var sections: [WebSection] = []
    var servings: Int = 0
    var directions: [String] = []
    
    init(id: Int, name: String, imageURL: String, sections: [WebSection], servings: Int, directions: [String]) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.sections = sections
        self.servings = servings
        self.directions = directions
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
}
