//
//  UnitOfMeasurement.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

// TODO: localization for unit names
// used for representing a unit of measurement for ingredients
enum UnitOfMeasurement: CaseIterable {
    case cup
    case pint
    case quart
    case gallon
    case teaspoon
    case tablespoon
    case liter
    case mililiter
    case pound
    case ounce
    case fluidOunce
    case gram
    case kilogram
    case milligram
    case none
    case unknown(String)
    
    func getName() -> String {
        var singularName = ""
        switch self {
        case .cup: singularName = "cup"
        case .pint: singularName = "pint"
        case .quart: singularName = "quart"
        case .gallon: singularName = "gallon"
        case .teaspoon: singularName = "teaspoon"
        case .tablespoon: singularName = "tablespoon"
        case .liter: singularName = "liter"
        case .mililiter: singularName = "mililiter"
        case .pound: singularName = "pound"
        case .ounce: singularName = "ounce"
        case .fluidOunce: singularName = "fluid ounce"
        case .gram: singularName = "gram"
        case .kilogram: singularName = "kilogram"
        case .milligram: singularName = "milligram"
        case .none: singularName = ""
        case .unknown(let unitName): singularName = unitName
        }
        return singularName
    }
    
    func getName(plural: Bool) -> String {
        var singularName = ""
        switch self {
        case .cup: singularName = "cup"
        case .pint: singularName = "pint"
        case .quart: singularName = "quart"
        case .gallon: singularName = "gallon"
        case .teaspoon: singularName = "teaspoon"
        case .tablespoon: singularName = "tablespoon"
        case .liter: singularName = "liter"
        case .mililiter: singularName = "mililiter"
        case .pound: singularName = "pound"
        case .ounce: singularName = "ounce"
        case .fluidOunce: singularName = "fluid ounce"
        case .gram: singularName = "gram"
        case .kilogram: singularName = "kilogram"
        case .milligram: singularName = "milligram"
        case .none: singularName = ""
        case .unknown(let unitName): singularName = unitName
        }
        if plural {
            if singularName != "" {
                return singularName + "s"
            }
        }
        return singularName
    }
    
    func getShorthand() -> String {
        var singularShorthand = ""
        switch self {
        case .cup: singularShorthand = "c"
        case .pint: singularShorthand = "p"
        case .quart: singularShorthand = "q"
        case .gallon: singularShorthand = "gal"
        case .teaspoon: singularShorthand = "tsp"
        case .tablespoon: singularShorthand = "Tbsp"
        case .liter: singularShorthand = "L"
        case .mililiter: singularShorthand = "mL"
        case .pound: singularShorthand = "lb"
        case .ounce: singularShorthand = "oz"
        case .fluidOunce: singularShorthand = "fl oz"
        case .gram: singularShorthand = "g"
        case .kilogram: singularShorthand = "kg"
        case .milligram: singularShorthand = "mg"
        case .none: singularShorthand = ""
        case .unknown(let unitName): singularShorthand = unitName
        }
        return singularShorthand
    }
    
    static var allCases: [UnitOfMeasurement] {
        return [.cup, .pint, .quart, .gallon, .teaspoon, .tablespoon, .liter, .mililiter, .pound]
    }
    
    static func fromString(unitString: String) -> UnitOfMeasurement {
        for unit in UnitOfMeasurement.allCases {
            if unitString.lowercased() == unit.getName().lowercased() ||
                unitString.lowercased() == (unit.getName().lowercased() + "s") ||
                unitString.lowercased() == (unit.getShorthand().lowercased() + "s") ||
                unitString.lowercased() == unit.getShorthand().lowercased() {
                return unit
            }
        }
        return UnitOfMeasurement.unknown(unitString)
    }
    
    static func isUnknown(unitString: String) -> Bool {
        for unit in UnitOfMeasurement.allCases {
            if unitString.lowercased() == unit.getName().lowercased() ||
                unitString.lowercased() == (unit.getName().lowercased() + "s") ||
                unitString.lowercased() == (unit.getShorthand().lowercased() + "s") ||
                unitString.lowercased() == unit.getShorthand().lowercased() {
                return false
            }
        }
        return true
    }
}
