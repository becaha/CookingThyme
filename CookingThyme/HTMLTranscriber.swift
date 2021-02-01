//
//  HTMLTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/16/21.
//

import SwiftUI

// TODO: store urls -> recipe
// TODO: delish.com recipes are in divs not lists so they don't get found
class HTMLTranscriber: ObservableObject {
    var recipesStore = [String: Recipe]()
    
    func createTranscription(fromUrlString urlString: String, setRecipe: @escaping (Recipe?, String?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Error: \(urlString) doesn't seem to be a valid URL")
            setRecipe(nil, nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                DispatchQueue.main.async {
                    setRecipe(nil, nil)
                }
                return
            }
            
            var name = ""
            if let contents = try? String(contentsOf: url) {
                name = self.getTitle(fromHtml: contents)
            }
            
            if let recipeString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string {
//                self.printHTML(recipeString)
                let recipe = self.parseRecipe(recipeString, withName: name)
                DispatchQueue.main.async {
                    setRecipe(recipe, recipeString)
                }
            }
        }
        .resume()
    }
    
    // TODO: symbols in html like &numbers &#039
    func getTitle(fromHtml html: String) -> String {
        var cleanString = ""
        var inTag = false
        var currentTag = ""
        var title = ""
        var isTitle = false
        for char in html {
            if char == "<" {
                inTag = true
                currentTag = ""
                continue
            }
            else if char == ">" {
                if currentTag.lowercased() == "title" && title == "" {
                    isTitle = true
                }
                else {
                    if isTitle {
                        return title
                    }
                    isTitle = false
                }
                inTag = false
                continue
            }
            
            if inTag {
                currentTag.append(char)
            }
            else {
                if isTitle {
                    title.append(char)
                }
                cleanString.append(char)
            }
        }
        return title
    }
    
    // TODO: 1 1/2 cups (440 g), ignoring the stuff in parenthesis, just part of the name, no change with serving size
    func parseRecipe(_ recipeString: String, withName name: String) -> Recipe {
        enum CurrentPart {
            case serving
            case ingredient
            case direction
            case none
        }

        var servings = 0
        var ingredientStrings = [String]()
        var directionStrings = [String]()
        var hasStepNumbers = false
        let sections = recipeString.components(separatedBy: "\n\n")
        for section in sections {
            var currentPart = CurrentPart.none
            let lines = section.components(separatedBy: "\n")
            for line in lines {
                let cleanLine = removeFormat(line)
                let cleanLineHeader = removeAll(line)
                // look for new part of recipe
                if currentPart != CurrentPart.ingredient && currentPart != CurrentPart.direction && servings == 0 && (cleanLine.localizedCaseInsensitiveContains("serving") || cleanLine.localizedCaseInsensitiveContains("yield")) {
                    currentPart = CurrentPart.serving
                }
                if cleanLineHeader.lowercased() == "ingredients" {
                    currentPart = CurrentPart.ingredient
                    // takes the last section
                    ingredientStrings = []
                    continue
                }
                if cleanLineHeader.lowercased() == "directions" || cleanLineHeader.lowercased() == "instructions" || cleanLineHeader.lowercased() == "method" || cleanLineHeader.lowercased() == "steps" {
                    currentPart = CurrentPart.direction
                    // takes the last section
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
                    var direction = cleanLine
                    var step: Int?
                    var stepString = ""
                    var stepPunctuation = ""
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
                        else if stepString.count > 0 && char.isPunctuation {
                            stepPunctuation.append(char)
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
                        direction = String(direction[direction.index(direction.startIndex, offsetBy: stepString.count + stepPunctuation.count)...])
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
    
    // remove puncutation at beginning like bullet point
    // removes "\t" but not " "
    func removeFormat(_ line: String) -> String {
        var cleanLine = ""
        for char in line {
            if !char.isWhitespace || char == " " || char.isPunctuation {
                cleanLine.append(char)
            }
        }
        if cleanLine.count > 0, cleanLine.charAt(index: 0).isPunctuation || cleanLine.charAt(index: 0).isSymbol {
            cleanLine = String(cleanLine[cleanLine.index(cleanLine.startIndex, offsetBy: 1)...])
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
