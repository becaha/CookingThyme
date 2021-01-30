//
//  HTMLTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/16/21.
//

import SwiftUI

class HTMLTranscriber: ObservableObject {
    
    func createTranscription(fromUrlString urlString: String, setRecipe: @escaping (Recipe, String) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Error: \(urlString) doesn't seem to be a valid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            if let recipeString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string {
                let recipe = self.parseString(recipeString)
                DispatchQueue.main.async {
                    setRecipe(recipe, recipeString)
                }
            }
        }
        .resume()
    }
    
    // TODO: 1 and 1/2 cups (440 g) -> 1, nothing, and cups...
    func parseString(_ recipeString: String) -> Recipe {
        enum CurrentPart {
            case serving
            case ingredient
            case direction
            case none
        }

        var name = ""
        var servings = 0
        var ingredientStrings = [String]()
        var directionStrings = [String]()
        var hasStepNumbers = false
        let sections = recipeString.components(separatedBy: "\n\n")
        for section in sections {
            var prevLine = ""
            var currentPart = CurrentPart.none
            let lines = section.components(separatedBy: "\n")
            for line in lines {
                let cleanLine = removeSymbols(line)
                let cleanLineHeader = removeAll(line)
                // look for new part of recipe
                if currentPart != CurrentPart.ingredient && currentPart != CurrentPart.direction && servings == 0 && (cleanLine.localizedCaseInsensitiveContains("serving") || cleanLine.localizedCaseInsensitiveContains("yield")) {
//                    name = prevLine
                    currentPart = CurrentPart.serving
                }
                if cleanLineHeader.lowercased() == "ingredients" {
                    currentPart = CurrentPart.ingredient
                    // TODO: take the last section
                    ingredientStrings = []
                    continue
                }
                if cleanLineHeader.lowercased() == "directions" || cleanLineHeader.lowercased() == "instructions" || cleanLineHeader.lowercased() == "method" || cleanLineHeader.lowercased() == "steps" {
                    currentPart = CurrentPart.direction
                    // TODO: take the last section
                    directionStrings = []
                    continue
                }
                
                // add item to current part of recipe
                if currentPart == CurrentPart.serving {
                    let words = cleanLine.components(separatedBy: " ")
                    for word in words {
                        if let servingsNum = Int(word) {
                            servings = servingsNum
                            currentPart = CurrentPart.none
                        }
                    }
                }
        
                if currentPart == CurrentPart.ingredient {
                    ingredientStrings.append(cleanLine)
                }
                
                if currentPart == CurrentPart.direction {
                    // directions wants punctuation
                    var direction = removeFormat(line)
                    var step: Int?
                    var stepString = ""
                    for word in direction.components(separatedBy: .whitespaces) {
                        if word.lowercased().localizedCaseInsensitiveContains("step") {
                            // remove word and space after
                            direction.removeFirst(word.count + 1)
                        }
                        else {
                            break
                        }
                    }
                    for char in direction {
                        if char.isNumber {
                            stepString.append(char)
                        }
                        // 1. 1: 1-
                        else if char.isSymbol {
                            break
                        }
                        else {
                            break
                        }
                    }
                    // if direction includes a step number
                    if stepString.count  > 0 {
                        step = Int(String(stepString))
                        // remove number from direction
                        direction = String(direction[direction.index(direction.startIndex, offsetBy: stepString.count)...])
                        // found first direction
                        if step == 1 {
                            hasStepNumbers = true
                            directionStrings = [String]()
                        }
                        
                        directionStrings.append(direction)
                    }
                    // don't add a line that has no step number if the directions have step numbers
                    if !hasStepNumbers {
                        directionStrings.append(direction)
                    }
                }
                
                if cleanLine != "" {
                    prevLine = cleanLine
                }
            }
            // end of a section, if we have the recipe, stop parsing
            if ingredientStrings.count > 0 && directionStrings.count > 0 {
                break
            }
        }
        let directions = Direction.toDirections(directionStrings: directionStrings, withRecipeId: 0)
        let ingredients = Ingredient.toIngredients(fromStrings: ingredientStrings)
        
        return Recipe(name: name, ingredients: ingredients, directions: directions, images: [RecipeImage](), servings: servings)
    }
    
    // "\t", "\u{xxxx}"
    func removeSymbols(_ line: String) -> String {
        var cleanLine = ""
        for char in line {
            if char.isLetter || char.isNumber || char == " " {
                cleanLine.append(char)
            }
        }
        return cleanLine
    }
    
    // "\t", "\u{xxxx}"
    func removeAll(_ line: String) -> String {
        var cleanLine = ""
        for char in line {
            if char.isLetter || char.isNumber {
                cleanLine.append(char)
            }
        }
        return cleanLine
    }
    
    // remove weird punctuation, keep (: - ( ) )
    // removes "\t" but not " "
    func removeFormat(_ line: String) -> String {
        var cleanLine = ""
        for char in line {
            if !char.isWhitespace || char == " " {
                cleanLine.append(char)
            }
        }
        return cleanLine
    }
    
    func printHTML(_ recipeString: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("recipeString.txt")
            do {
                try recipeString.write(to: pathWithFilename,
                                     atomically: true,
                                     encoding: .utf8)
            } catch {
                // Handle error
            }
        }
    }
}

extension String {
    func charAt(index: Int) -> Character {
        self[self.index(self.startIndex, offsetBy: index)]
    }
}
