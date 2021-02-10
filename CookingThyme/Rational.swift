//
//  Rational.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

// represents a fraction, 1/2
struct Rational {
    let numerator: Int
    let denominator: Int
    
    init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }
    
    // denominator can be 10, 9, (8), 7, 6, 5, (4), (3), (2)
    // initializes Rational with a double and converts to closest rational, ex. 0.49 -> 1/2
    init(decimal: Double, allDenominators: Bool = false) {
        var rationalDistances = [(closestNumerator: Int, denominator: Int, closestDistance: Double)]()
        let closestTenth = Rational.findClosest(denominator: 10, decimal: decimal)
        let closestNinth = Rational.findClosest(denominator: 9, decimal: decimal)
        let closestEighth = Rational.findClosest(denominator: 8, decimal: decimal)
        let closestSeventh = Rational.findClosest(denominator: 7, decimal: decimal)
        let closestSixth = Rational.findClosest(denominator: 6, decimal: decimal)
        let closestThird = Rational.findClosest(denominator: 3, decimal: decimal)
        if allDenominators {
            rationalDistances.append(contentsOf: [closestTenth, closestNinth, closestEighth, closestSeventh, closestSixth, closestThird])
        }
        else {
            rationalDistances.append(contentsOf: [closestEighth, closestThird])
        }
        
        var fraction: (numerator: Int, denominator: Int)
        var closestRationalDistance = closestTenth
        if let minRationalDistance = rationalDistances.min(by: { $0.closestDistance < $1.closestDistance }) {
            closestRationalDistance = minRationalDistance
        }
        fraction = Rational.reduce(numerator: closestRationalDistance.closestNumerator, denominator: closestRationalDistance.denominator)
        self.init(numerator: fraction.numerator, denominator: fraction.denominator)
    }
    
    // reduces the fraction
    static func reduce(numerator: Int, denominator: Int) -> (numerator: Int, denominator: Int) {
        var newNumerator = numerator
        var newDenominator = denominator
        var canReduce = true
        
        while canReduce {
            let factors = Rational.findFactors(num: numerator).reversed()
            var didReduce = false
            for factor in factors {
                if newNumerator % factor == 0 && newDenominator % factor == 0 && factor != 1 {
                    newNumerator /= factor
                    newDenominator /= factor
                    didReduce = true
                    break
                }
            }
            if !didReduce {
                canReduce = false
                break
            }
        }
        return (newNumerator, newDenominator)
    }
    
    // finds factors of num
    static func findFactors(num: Int) -> [Int] {
        var factors = [Int]()
        if num == 0 {
            return factors
        }
        var endFactor = num
        for i in 1...num {
            if i == endFactor {
                return factors
            }
            if num % i == 0 {
                factors.append(i)
                factors.append(num / i)
                endFactor = num / i
            }
        }
        return factors
    }
    
    // finds closest fraction to decimal with accuracy of 1/3 and 1/8's
    // smaller is true if closest fraction must be smaller than the decimal
    static func findClosest(denominator: Int, decimal: Double, smaller: Bool = true) -> (closestNumerator: Int, denominator: Int, closestDistance: Double) {
        var closestNumerator: Int = 0
        if !smaller {
            closestNumerator = 1
        }
        var closestDistance: Double = abs((Double(closestNumerator) / Double(denominator)) - decimal)
        if smaller {
            closestDistance = decimal
        }
        for numerator in (closestNumerator + 1)..<denominator {
            var distance = abs((Double(numerator) / Double(denominator)) - decimal)
            if smaller {
                distance = decimal - (Double(numerator) / Double(denominator))
            }
            if distance < closestDistance && distance >= 0 {
                closestDistance = distance
                closestNumerator = numerator
            }
            // found exact fraction or went larger than decimal, return
            if distance <= 0 {
                break
            }
        }
        return (closestNumerator, denominator, abs(closestDistance))
    }
}
