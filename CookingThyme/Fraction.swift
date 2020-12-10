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
    
    enum VulgarFraction: String {
        case one_eighth = "\u{215B}"
        case one_fourth = "\u{BC}"
        case one_third = "\u{2153}"
        case three_eighths = "\u{215C}"
        case one_half = "\u{BD}"
        case five_eighths = "\u{215D}"
        case two_thirds = "\u{2154}"
        case three_fourths = "\u{BE}"
        case seven_eighths = "\u{215E}"
        
        case five_sixths = "\u{215A}"
        case four_fifths = "\u{2158}"
        case three_fifths = "\u{2157}"
        case two_fifths = "\u{2156}"
        case one_fifth = "\u{2155}"
        case one_sixth = "\u{2159}"
        case one_seventh = "\u{2150}"
        case one_ninth = "\u{2151}"
        case one_tenth = "\u{2152}"
        
        static func getFractionComponents(fraction: String) -> [String] {
            var fractionComponents = [String]()
            switch fraction {
            case VulgarFraction.one_tenth.rawValue,
                 VulgarFraction.one_ninth.rawValue,
                 VulgarFraction.one_eighth.rawValue,
                 VulgarFraction.one_seventh.rawValue,
                 VulgarFraction.one_sixth.rawValue:
                fractionComponents = ["1", "8"] // .125
            case VulgarFraction.one_fifth.rawValue,
                 VulgarFraction.one_fourth.rawValue:
                fractionComponents = ["1", "4"] // .25
            case VulgarFraction.one_third.rawValue:
                fractionComponents = ["1", "3"] // .33
            case VulgarFraction.three_eighths.rawValue,
                 VulgarFraction.two_fifths.rawValue:
                fractionComponents = ["3", "8"] // .375
            case VulgarFraction.one_half.rawValue:
                fractionComponents = ["1", "2"] // .5
            case VulgarFraction.three_fifths.rawValue,
                 VulgarFraction.five_eighths.rawValue:
                fractionComponents = ["5", "8"] // .625
            case VulgarFraction.two_thirds.rawValue:
                fractionComponents = ["2", "3"] // .67
            case VulgarFraction.three_fourths.rawValue,
                 VulgarFraction.four_fifths.rawValue:
                fractionComponents = ["3", "4"] // .75
            case VulgarFraction.five_sixths.rawValue,
                 VulgarFraction.seven_eighths.rawValue:
                fractionComponents = ["7", "8"] // .875
            default:
                fractionComponents = []
            }
            return fractionComponents
        }
    }
    
    static func getFractionPieces(_ fraction: String) -> [String] {
        let pieces = fraction.components(separatedBy: "/")
        if pieces.count == 1 {
            return VulgarFraction.getFractionComponents(fraction: pieces[0])
        }
        return pieces
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
            let fraction = getFractionPieces(pieces[nextPiece])
            if fraction.count != 0 {
                let rational = Rational(numerator: fraction[0].toInt(), denominator: fraction[1].toInt())
                return Fraction(whole: whole, rational: rational)
            }
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
