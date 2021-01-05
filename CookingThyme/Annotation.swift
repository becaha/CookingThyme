//
//  Annotation.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/4/21.
//

import Foundation

struct Annotation {
    var description: String
    var boundingPoly: [(Int, Int)]
    
    init(description: String, boundingPoly: [(Int, Int)]) {
        self.description = description
        self.boundingPoly = boundingPoly
    }
    
    init() {
        description = ""
        boundingPoly = [(Int, Int)]()
    }
}
