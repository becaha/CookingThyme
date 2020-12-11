//
//  Rational.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

// represents a fraction, 1/2
struct Rational {
    let numerator : Int
    let denominator: Int

    init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }
    
    // TODO use tablespoons and teaspoons for smaller measures
    // denominator can be 8, 4, 3, 2
    // initializes Rational with a double and converts to closest rational, ex. 0.49 -> 1/2
    init(decimal: Double) {
        let closestEighth = Rational.findClosest(denominator: 8, decimal: decimal)
        let closestThird = Rational.findClosest(denominator: 3, decimal: decimal)
        
        var fraction: (numerator: Int, denominator: Int)
        if closestThird.closestDistance <= closestEighth.closestDistance {
            fraction = Rational.reduce(numerator: closestThird.closestNumerator, denominator: 3)
        }
        else {
            fraction = Rational.reduce(numerator: closestEighth.closestNumerator, denominator: 8)
        }
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
    static func findClosest(denominator: Int, decimal: Double) -> (closestNumerator: Int, closestDistance: Double) {
        var closestNumerator: Int = 1
        var closestDistance: Double = abs((1.0 / Double(denominator)) - decimal)
        for numerator in 2..<denominator {
            let distance = abs((Double(numerator) / Double(denominator)) - decimal)
            if distance < closestDistance {
                closestDistance = distance
                closestNumerator = numerator
            }
        }
        return (closestNumerator, abs(closestDistance))
    }
}
