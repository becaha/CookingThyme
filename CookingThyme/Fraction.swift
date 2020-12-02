//
//  Fraction.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

struct Fraction {
    var whole: Int
    var rational: Rational?
    
    static func toFraction(fromString amountString: String) -> Fraction {
        if let amountDouble = Double(amountString) {
            return toFraction(fromDouble: amountDouble)
        }
        else {
            return toFraction(fromFractionString: amountString)
        }
    }
    
    static func toFraction(fromFractionString fractionString: String) -> Fraction {
        let pieces = fractionString.components(separatedBy: " ")
        var nextPiece = 0
        var whole = 0
        if let wholePiece = Int(pieces[nextPiece]) {
            whole = wholePiece
            nextPiece += 1
        }
        if pieces.count > nextPiece {
            let fraction = pieces[nextPiece].components(separatedBy: "/")
            let rational = Rational(numerator: fraction[0].toInt(), denominator: fraction[1].toInt())
            return Fraction(whole: whole, rational: rational)
        }
        return Fraction(whole: whole, rational: nil)
    }
    
    static func toDouble(fromString string: String) -> Double {
        let fraction = toFraction(fromString: string)
        return toDouble(fromFraction: fraction)
    }
    
    static func toDouble(fromFraction fraction: Fraction) -> Double {
        var rationalDouble: Double = 0
        if let rational = fraction.rational {
            rationalDouble = Double(rational.numerator) / Double(rational.denominator)
        }
        return Double(fraction.whole) + rationalDouble
    }
    
    static func toFraction(fromDouble double: Double) -> Fraction {
        let decimalPart = double.truncatingRemainder(dividingBy: 1)
        let wholePart = Int(double - decimalPart)
        if decimalPart == 0 {
            return Fraction(whole: wholePart, rational: nil)
        }
        let rational = Rational.init(decimal: decimalPart)
        
        return Fraction(whole: wholePart, rational: rational)
    }
    
    static func toString(fromDouble double: Double) -> String {
        let fraction = toFraction(fromDouble: double)
        return toString(fromFraction: fraction)
    }
    
    static func toString(fromFraction fraction: Fraction) -> String {
        if let rational = fraction.rational {
            if fraction.whole == 0 {
                return "\(rational.numerator)/\(rational.denominator)"
            }
            return "\(fraction.whole) \(rational.numerator)/\(rational.denominator)"
        }
        else {
            return "\(fraction.whole)"
        }
    }
}
