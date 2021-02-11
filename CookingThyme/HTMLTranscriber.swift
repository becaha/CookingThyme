//
//  HTMLTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/16/21.
//

import SwiftUI

// TODO: delish.com recipes are in divs not lists so they don't get found
class HTMLTranscriber: ObservableObject {
    var recipesStore = [String: (recipe: Recipe, recipeText: String)]()
    
    func createTranscription(fromUrlString urlString: String, setRecipe: @escaping (Recipe?, String?) -> Void) {
        let storedRecipe = self.recipesStore[urlString]
        if let storedRecipe = storedRecipe {
            setRecipe(storedRecipe.recipe, storedRecipe.recipeText)
            return
        }
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
            var htmlString = ""
            if let contents = try? String(contentsOf: url) {
                htmlString = contents
                name = HTMLTranscriber.cleanHtmlTags(fromHtml: htmlString, returnTitle: true)
            }
            
            if let recipeString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string {
//                self.printHTML(recipeString)
                let recipe = self.parseRecipe(recipeString, withName: name, recipeURL: urlString)
//                if !self.isValid(recipe) {
//                    let cleanRecipeString = HTMLTranscriber.cleanHtmlTags(fromHtml: htmlString, returnTitle: false)
//                    recipe = self.parseRecipe(cleanRecipeString, withName: name, recipeURL: urlString)
//                }
                self.recipesStore[urlString] = (recipe: recipe, recipeText: recipeString)
                DispatchQueue.main.async {
                    setRecipe(recipe, recipeString)
                }
            }
            else {
                DispatchQueue.main.async {
                    setRecipe(nil, nil)
                }
            }
        }
        .resume()
    }
    
    // recipe is valid
    func isValid(_ recipe: Recipe) -> Bool {
        if recipe.name == "", recipe.directions.count == 0, recipe.ingredients.count == 0 {
            return false
        }
        return true
    }
    
    // <ul><li>thing</li><li>thing2</li>
    // <title>the title</title>
    // TODO: symbols in html like &numbers &#039
    static func cleanHtmlTags(fromHtml html: String, returnTitle: Bool) -> String {
        var cleanString = ""
        var inTag = false
        var currentTag = ""
        var text = ""
        var title = ""
        var isTitle = false
        // if there are no tags, return original string
        if !html.contains("<") {
            return html
        }
        for char in html {
            // start of tag
            if char == "<" {
                inTag = true
                // section off the text sectioned in the tags by adding new line to string
                if text != "" && currentTag.lowercased() != "script" {
                    cleanString.append(text)
                    cleanString.append("\n")
                }
                text = ""
                currentTag = ""
            }
            // end of tag
            else if char == ">" {
                if returnTitle {
                    if currentTag.lowercased() == "title" && title == "" {
                        isTitle = true
                    }
                    else {
                        if isTitle {
                            return title
                        }
                        isTitle = false
                    }
                }
                inTag = false
            }
            else {
                if inTag {
                    currentTag.append(char)
                }
                else {
                    if returnTitle, isTitle {
                        title.append(char)
                    }
                    text.append(char)
                }
            }
        }
        
        if returnTitle {
            return title
        }
        // remove last \n
        if cleanString.count > 0 {
            cleanString.removeLast(1)
            return cleanString
        }
        return ""
    }
    
    // TODO: 1 1/2 cups (440 g), ignoring the stuff in parenthesis, just part of the name, no change with serving size
    func parseRecipe(_ recipeString: String, withName name: String, recipeURL: String) -> Recipe {
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
            var lines = section.components(separatedBy: "\n")
            lines = lines.filter { (line) -> Bool in
                // line is not only whitespace and line is not empty string
                !line.trimmingCharacters(in: .whitespaces).isEmpty && line != ""
            }
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
                            servings = max(servingsNum, 0)
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
        
        return Recipe(name: name, ingredients: ingredients, directions: directions, images: [RecipeImage](), servings: servings, source: recipeURL)
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
