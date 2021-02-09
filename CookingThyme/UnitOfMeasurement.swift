//
//  UnitOfMeasurement.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

enum UnitType {
    case mass
    case volume
    case none
}

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
    
    func getUnit() -> Unit? {
        var unit: Unit?
        switch self {
        case .cup: unit = UnitVolume.cups
        case .pint: unit = UnitVolume.pints
        case .quart: unit = UnitVolume.quarts
        case .gallon: unit = UnitVolume.gallons
        case .teaspoon: unit = UnitVolume.teaspoons
        case .tablespoon: unit = UnitVolume.tablespoons
        case .liter: unit = UnitVolume.liters
        case .mililiter: unit = UnitVolume.milliliters
        case .pound: unit = UnitMass.pounds
        case .ounce: unit = UnitMass.ounces
        case .fluidOunce: unit = UnitVolume.fluidOunces
        case .gram: unit = UnitMass.grams
        case .kilogram: unit = UnitMass.kilograms
        case .milligram: unit = UnitMass.milligrams
        case .none: unit = nil
        case .unknown(_): unit = nil
        }
        return unit
    }
    
    func getName(plural: Bool = false) -> String {
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
        case .cup: singularShorthand = "cup"
        case .pint: singularShorthand = "pt"
        case .quart: singularShorthand = "qt"
        case .gallon: singularShorthand = "gal"
        case .teaspoon: singularShorthand = "tsp"
        case .tablespoon: singularShorthand = "tbsp"
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
    
    func caseType() -> UnitType {
        if UnitOfMeasurement.volCases.contains(where: { (unit) -> Bool in
            unit.getName() == self.getName()
        }) {
            return UnitType.volume
        }
        else if UnitOfMeasurement.massCases.contains(where: { (unit) -> Bool in
            unit.getName() == self.getName()
        }) {
            return UnitType.mass
        }
        return UnitType.none
    }
    
    static var allCases: [UnitOfMeasurement] {
        var allCases = volCases
        allCases.append(contentsOf: massCases)
        return allCases
    }
    
    static var massCases: [UnitOfMeasurement] {
        var massCases = massGramCases
        massCases.append(contentsOf: massPoundCases)
        return massCases
    }
    
    static var volCases: [UnitOfMeasurement] {
        var volCases = volGalCases
        volCases.append(contentsOf: volLiterCases)
        return volCases
    }
    
    static var volGalCases: [UnitOfMeasurement] {
        return [.gallon, .quart, .pint, .cup, .tablespoon, .teaspoon]
    }
    
    static var volLiterCases: [UnitOfMeasurement] {
        return [.liter, .mililiter]
    }
    
    static var massGramCases: [UnitOfMeasurement] {
        return [.kilogram, .gram, milligram]
    }
    
    static var massPoundCases: [UnitOfMeasurement] {
        return [.pound, .ounce]
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
