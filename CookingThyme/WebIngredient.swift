//
//  WebIngredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

struct WebIngredient {
    var name: String = ""
    var measurements: [WebMeasurement] = []

    init(name: String, measurements: [WebMeasurement]) {
        self.name = name
        self.measurements = measurements
    }
    
    init() {}
}
