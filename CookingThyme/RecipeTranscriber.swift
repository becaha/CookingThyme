//
//  RecipeTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/16/21.
//

import Foundation
import SwiftUI

class RecipeTranscriber {
    @Published var recipe: Recipe?
    @Published var recipeText: String?
    private var imageTranscriber = ImageTranscriber()
    private var htmlTranscriber = HTMLTranscriber()
    
    func createTranscription(fromUrlString urlString: String) {
        htmlTranscriber.createTranscription(fromUrlString: urlString) { recipe, recipeText in
            self.setRecipe(recipe, withText: recipeText)
        }
    }
    
    func setRecipe(_ recipe: Recipe?, withText text: String?) {
        self.recipe = recipe
        self.recipeText = text
    }

    func createTranscription(fromImage uiImage: UIImage) {
        imageTranscriber.createTranscription(fromImage: uiImage) { transcription in
            self.setTranscription(transcription)
        }
    }

    let MAX_SPACE_X = 250
    let MAX_SPACE_Y = 10
    var fonts:[Int] = []
    
    func setTranscription(_ transcription: Transcription) {
        self.recipe = analyzeTranscription(transcription)
        self.recipeText = transcription.annotations[0].description

    }
    
    

    //check to see if the space between the two annotations is the right ammount of space
    //between two words in a sentence
    func isInLine(left leftAnnPos:Vertex,right rightAnnPos:Vertex)-> Bool{
        if ((abs(rightAnnPos.x - leftAnnPos.x) > MAX_SPACE_X) || (abs(rightAnnPos.y - leftAnnPos.y) > MAX_SPACE_Y)) {
            return false
        }
        return true
    }
    
    //checks the given difference in y-space and returns a font size
    func getFontSize(topToBottom rawFontSize:Int)->Int{
        //if fonts is not populated yet, this is the first font size
        for currFont:Int in fonts {
            if ((rawFontSize >= (currFont - 6)) && (rawFontSize <= (currFont + 6))){
                return currFont
            }
        }
        //if there are no matches return a new font size
        fonts.append(rawFontSize)
        return rawFontSize
    }
    
    // TODO: DAN's function
    func analyzeTranscription(_ transcription: Transcription) -> Recipe {
        // first annotation is the whole recipe in text including new lines

        //index the vertecies by their location
        let topLeft = 0
        let topRight = 1
        let bottomRight = 2
        let bottomLeft = 3
        //variable init for max and min values of vertecies
//        var minX = 0
//        var minY = 0
//        var maxX = 0
//        var maxY = 0
        
        //bools
        var lookingForTitle = true
        var ingredientsLocationSet = false
        var directionsLocationSet = false
        var isDirection = false
        var isIngredient = false

        //key font sizes init
        var maxFontSize = 0
        var currFontHeight = 0
        var currFontSize = 0

        //location values for ingredients and directions
        var ingredientsLocationX = 0
        var ingredientsLocationY = 0
        var directionLocationX = 0
        var directionLocationY = 0
        
        var currLine = ""

        //dictionary for holding each section
        var sections = [String:[String]]()
        sections = ["title" : [] , "ingredients": [] , "directions" : []]
        
        //the recipe title
        var title:String = ""

        //the last annotation
        var lastAnnotation:Annotation = transcription.annotations[0]
        
        
        //loop through each annotation enumerating each index
        //this loop finds the title of the recipe by comparing its relative font size
        //theis loop also will separate lines into sections based on their location
        for index in 0..<transcription.annotations.count {
            var x = 0
            var y = 0
            let boundingPoly = transcription.annotations[index].boundingPoly
            let lastAnn_boundingPoly = lastAnnotation.boundingPoly
            //get all vertecies from bounding poly for current annotation
            for vertex in boundingPoly{
                x = vertex.x
                y = vertex.y
            }
          
          //going into the first annotation only which should include the whole recipe
          //in its description
//            if index == 0 {
//                //set min and max values where annotations will appear
//                minX = boundingPoly[topLeft].x
//                minY = boundingPoly[topLeft].y
//                maxX = boundingPoly[topRight].x
//                maxY = boundingPoly[bottomRight].y
//                //print(annotation["description"])
//            }

          //get the description which is the word or string value from the annotation
            let description = transcription.annotations[index].description

          //set the locations of keywords like ingredients or directions
            if (!ingredientsLocationSet && index > 1 && (description.localizedCaseInsensitiveContains("ingredient"))){
                ingredientsLocationX = boundingPoly[topLeft].x
                ingredientsLocationY = boundingPoly[topLeft].y
                ingredientsLocationSet = true
            }

            if (!directionsLocationSet && index > 1 && (description.localizedCaseInsensitiveContains("direction") || description.localizedCaseInsensitiveContains("method") || description.localizedCaseInsensitiveContains("instruction") || description.localizedCaseInsensitiveContains("step"))) {
                directionLocationX = boundingPoly[topLeft].x
                directionLocationY = boundingPoly[topLeft].y
                directionsLocationSet = true
            }

          //check if current annotation is in the current line
            if (isInLine(left: boundingPoly[topRight],right: lastAnn_boundingPoly[topLeft]) && !lookingForTitle){
                currLine = currLine + description + " "
            }
            else{
                if (currLine != ""){
                    if (isIngredient) {
                        sections["ingredients"]?.append(currLine)
                    }
                    else if (isDirection) {
                        sections["directions"]?.append(cleanDirection(currLine))
                    }
                    currLine = description + " "
                    if (ingredientsLocationSet) {
                        if (directionsLocationSet &&
                            (x >= (directionLocationX - 20) || x <= (directionLocationX + 20)) &&
                            y > directionLocationY) {
                            isIngredient = false
                            isDirection = true
                        }
                        else if ((x >= (ingredientsLocationX - 20) || x <= (ingredientsLocationX + 20)) &&
                              (y > ingredientsLocationY)) {
                            isDirection = false
                            isIngredient = true
                        }
                        else {
                            isDirection = false
                            isIngredient = false
                        }
                     }
                  }
              }
                  

            if (lookingForTitle && index != 0){
                //check if current annotation has max font size
                currFontHeight = boundingPoly[bottomLeft].y - boundingPoly[topLeft].y

                currFontSize = getFontSize(topToBottom: currFontHeight)

                //check is the current annotation, besides the first, has the largest font size
                if currFontSize > maxFontSize && index != 0 {
                    maxFontSize = currFontSize
                }
                //if the current font size is max then it should be a part of the title
                if currFontSize == maxFontSize {
                    title += (description + " ")
                }
                if (currFontSize < maxFontSize) {
                    lookingForTitle = false
                    sections["title"]?.append(title)
                    currLine = description + " "
                }
            }
            lastAnnotation = transcription.annotations[index]
        }
        
        var ingredients = [Ingredient]()
        var directions = [Direction]()
        let recipe_title = sections["title"]?[0] ?? ""
        
        for ing in (sections["ingredients"] ?? []) {
            ingredients.append(Ingredient(ingredientString: ing))
        }
        var stepNum = 0
        for dir in (sections["directions"] ?? []) {
            directions.append(Direction(step: stepNum, direction: dir))
            stepNum += 1
        }
        let imageRecipe:Recipe = Recipe(name: recipe_title, ingredients: ingredients, directions: directions, images: [], servings: 0, source: "")

        return imageRecipe
    }
    
    func cleanDirection(_ direction: String) -> String {
        var direction = HTMLTranscriber.removeFormat(direction)
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
            // remove number from direction
            direction = String(direction[direction.index(direction.startIndex, offsetBy: stepString.count + stepPunctuation.count)...])
        }
        
        return direction
    }
    
    func printTranscriptionJson(_ transcription: Transcription) {
        if let encodedData = try? JSONEncoder().encode(transcription) {
            let jsonString = String(data: encodedData,
                                    encoding: .utf8)
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                in: .userDomainMask).first {
                let pathWithFilename = documentDirectory.appendingPathComponent("transcription.json")
                do {
                    try jsonString?.write(to: pathWithFilename,
                                         atomically: true,
                                         encoding: .utf8)
                } catch {
                    // Handle error
                }
            }
        }
    }
    
}
