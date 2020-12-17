//
//  WebMeasurement.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

struct WebMeasurement {
    var quantity: String = "1"
    var unit: WebUnit = WebUnit()
    
    init(quantity: String, unit: WebUnit) {
        self.quantity = quantity
        self.unit = unit
    }
    
    init() {}
}
