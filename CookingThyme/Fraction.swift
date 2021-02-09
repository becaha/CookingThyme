//
//  Fraction.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

// represents a fraction with a whole part like 1 1/2
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
    
    // for getting fraction meaning from vulgar fraction
    enum VulgarFraction: String {
        case one_tenth = "\u{2152}"
        case one_ninth = "\u{2151}"
        case one_eighth = "\u{215B}"
        case one_seventh = "\u{2150}"
        case one_sixth = "\u{2159}"
        case one_fifth = "\u{2155}"
        case one_fourth = "\u{BC}"
        case one_third = "\u{2153}"
        case three_eighths = "\u{215C}"
        case two_fifths = "\u{2156}"
        case one_half = "\u{BD}"
        case three_fifths = "\u{2157}"
        case five_eighths = "\u{215D}"
        case two_thirds = "\u{2154}"
        case three_fourths = "\u{BE}"
        case four_fifths = "\u{2158}"
        case five_sixths = "\u{215A}"
        case seven_eighths = "\u{215E}"

        static func getFractionComponents(fraction: String) -> [String] {
            var fractionComponents = [String]()
            switch fraction {
            case VulgarFraction.one_tenth.rawValue:
                fractionComponents = ["1", "10"] // .1
            case VulgarFraction.one_ninth.rawValue:
                fractionComponents = ["1", "9"] // .111
            case VulgarFraction.one_eighth.rawValue:
                 fractionComponents = ["1", "8"] // .125
            case VulgarFraction.one_seventh.rawValue:
                fractionComponents = ["1", "7"] // .143
            case VulgarFraction.one_sixth.rawValue:
                fractionComponents = ["1", "6"] // .167
            case VulgarFraction.one_fifth.rawValue:
                fractionComponents = ["1", "5"] // .2
            case VulgarFraction.one_fourth.rawValue:
                fractionComponents = ["1", "4"] // .25
            case VulgarFraction.one_third.rawValue:
                fractionComponents = ["1", "3"] // .33
            case VulgarFraction.three_eighths.rawValue:
                fractionComponents = ["3", "8"] // .375
            case VulgarFraction.two_fifths.rawValue:
                fractionComponents = ["2", "5"] // .4
            case VulgarFraction.one_half.rawValue:
                fractionComponents = ["1", "2"] // .5
            case VulgarFraction.three_fifths.rawValue:
                fractionComponents = ["3", "5"] // .6
            case VulgarFraction.five_eighths.rawValue:
                fractionComponents = ["5", "8"] // .625
            case VulgarFraction.two_thirds.rawValue:
                fractionComponents = ["2", "3"] // .67
            case VulgarFraction.three_fourths.rawValue:
                fractionComponents = ["3", "4"] // .75
            case VulgarFraction.four_fifths.rawValue:
                fractionComponents = ["4", "5"] // .8
            case VulgarFraction.five_sixths.rawValue:
                fractionComponents = ["5", "6"] // .833
            case VulgarFraction.seven_eighths.rawValue:
                fractionComponents = ["7", "8"] // .875
            default:
                fractionComponents = []
            }
            return fractionComponents
        }
    }
    
    // gets fraction pieces from string "1/2" and symbol "½" -> 1, 2
    static func getFractionPieces(_ fraction: String) -> [String] {
        let pieces = fraction.components(separatedBy: "/")
        if pieces.count == 1 {
            return VulgarFraction.getFractionComponents(fraction: pieces[0])
        }
        return pieces
    }
    
    func isPlural() -> Bool {
        return self.whole > 1 || (self.whole == 1 && self.rational != nil)
    }
    
    // MARK: - Fraction Conversions (Doubles, Fractions, Strings)
    // the amounts are stored in db as doubles and shown in UI as strings
    // the Fraction and Rational classes are used to help the conversion from double -> string and back
    
    // converts fraction string to Fraction
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
    
    // converts double to Fraction
    static func toFraction(fromDouble double: Double, allDenominators: Bool = false) -> Fraction {
        let decimalPart = double.truncatingRemainder(dividingBy: 1)
        let wholePart = Int(double - decimalPart)
        if decimalPart == 0 {
            return Fraction(whole: wholePart, rational: nil)
        }
        let rational = Rational.init(decimal: decimalPart, allDenominators: allDenominators)
        if rational.numerator == 0 {
            return Fraction(whole: wholePart, rational: nil)
        }
        return Fraction(whole: wholePart, rational: rational)
    }
    
    // converts fraction string to double
    static func toDouble(fromString string: String) -> Double {
        let fraction = toFraction(fromString: string)
        return toDouble(fromFraction: fraction)
    }
    
    // converts Fraction to double
    static func toDouble(fromFraction fraction: Fraction) -> Double {
        var rationalDouble: Double = 0
        if let rational = fraction.rational {
            rationalDouble = Double(rational.numerator) / Double(rational.denominator)
        }
        return Double(fraction.whole) + rationalDouble
    }
    
    // converts double to string
    static func toString(fromDouble double: Double) -> String {
        let fraction = toFraction(fromDouble: double)
        return toString(fromFraction: fraction)
    }
    
    // converts Fraction to string
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
