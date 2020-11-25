//
//  UnitOfMeasurement.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

// TODO: idk the measurement shorthands

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
        case .unknown(let unitName): singularName = unitName
        }
        if plural {
            return singularName + "s"
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
        case .unknown(let unitName): singularShorthand = unitName
        }
        return singularShorthand
    }
    
    static var allCases: [UnitOfMeasurement] {
        return [.cup, .pint, .quart, .gallon, .teaspoon, .tablespoon, .liter, .mililiter, .pound]
    }
    
    // TODO what to do with unknown unit
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
}
