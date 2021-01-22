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
//                self.printHTML(recipeString)
                let recipe = self.parseString(recipeString)
                DispatchQueue.main.async {
                    setRecipe(recipe, recipeString)
                }
            }
        }
        .resume()
    }
    
    // TODO: 1 and 1/2 cups (440 g)
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
        let sections = recipeString.components(separatedBy: "\n\n")
        for section in sections {
            var prevLine = ""
            var currentPart = CurrentPart.none
            let lines = section.components(separatedBy: "\n")
            for line in lines {
                let cleanLine = removeSymbols(line)
                // look for new part of recipe
                if cleanLine.localizedCaseInsensitiveContains("serving") {
                    name = prevLine
                    currentPart = CurrentPart.serving
                }
                if cleanLine.lowercased() == "ingredients" {
                    currentPart = CurrentPart.ingredient
                    // TODO: take the last section
                    ingredientStrings = []
                    continue
                }
                if cleanLine.lowercased() == "directions" || cleanLine.lowercased() == "instructions" {
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
                    directionStrings.append(cleanLine)
                }
                
                if cleanLine != "" {
                    prevLine = cleanLine
                }
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

