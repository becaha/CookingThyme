//
//  UnitOfMeasurement.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

// TODO: idk the measurement shorthands

enum UnitOfMeasurement: String, CaseIterable {
    case Cup = "cup"
    case Pint = "pint"
    case Quart = "quart"
    case Gallon = "gallon"
    case Teaspoon = "teaspoon"
    case Tablespoon = "tablespoon"
    case Liter = "liter"
    case MiliLiter = "mililiter"
    case Pound = "pound"
    case Unknown = "unknown"
    
    // TODO what to do with unknown unit
    static func fromString(unitString: String) -> UnitOfMeasurement {
        for unit in UnitOfMeasurement.allCases {
            if unitString.lowercased() == unit.rawValue.lowercased() {
                return unit
            }
        }
        return UnitOfMeasurement.Unknown
    }
}
