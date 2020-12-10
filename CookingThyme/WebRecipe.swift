//
//  WebRecipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

struct WebRecipe: Identifiable {
    var id: NSNumber?
    var name: String?
    var sections: [WebSection]?
    var servings: NSNumber?
    var directions: [String]?
    
    init(id: NSNumber, name: String?, sections: [WebSection]?, servings: NSNumber?, directions: [String]?) {
        self.id = id
        self.name = name
        self.sections = sections
        self.servings = servings
        self.directions = directions
    }
    
    init() {}
    
}
