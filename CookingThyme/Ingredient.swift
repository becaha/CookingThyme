//
//  Ingredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

struct Ingredient: Identifiable {
    var name: String
    var amount: Double
    var unit: UnitOfMeasurement
    var id: UUID
    
    init(name: String, amount: Double, unit: UnitOfMeasurement) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.id = UUID()
    }
    
    func getFractionAmount() -> String {
        let decimalPart = amount.truncatingRemainder(dividingBy: 1)
        let wholePart = Int(amount - decimalPart)
        if decimalPart == 0 {
            return "\(wholePart)"
        }
        let rational = Rational.init(decimal: decimalPart)
        
        return "\(wholePart) \(rational.numerator)/\(rational.denominator)"
    }
}
