//
//  UnitOfMeasurement.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

// TODO: idk the measurement shorthands

// TODO: check if is correct unit of measure, (if not, should we add it? should we give them only a set of units to pick from?
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
        case .none: singularName = ""
        case .unknown(let unitName): singularName = unitName
        }
        //TODO and not none
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
        case .none: singularShorthand = ""
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
