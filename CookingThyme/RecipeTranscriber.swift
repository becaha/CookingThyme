//
//  RecipeTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/16/21.
//

import Foundation
import SwiftUI

class RecipeTranscriber: ObservableObject {
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
        imageTranscriber.createTranscription(fromImage: uiImage) { recipe, recipeText in
            self.setRecipe(recipe, withText: recipeText)
        }
    }
    
    static func isIngredientsHeader(line: String) -> Bool {
        let cleanLines = line.components(separatedBy: .whitespaces).filter { (word) -> Bool in
            !word.isOnlyWhitespace()
        }
        if cleanLines.count == 0 {
            return false
        }
        let cleanLine = HTMLTranscriber.removeAll(cleanLines[0])
        return cleanLines.count == 1 && cleanLine.lowercased() == "ingredients"
    }
    
    static func isDirectionsHeader(line: String) -> Bool {
        let cleanLines = line.components(separatedBy: .whitespaces).filter { (word) -> Bool in
            !word.isOnlyWhitespace()
        }
        
        if cleanLines.count == 0 {
            return false
        }
        let cleanLine = HTMLTranscriber.removeAll(cleanLines[0])
        
        return cleanLines.count == 1 &&
                (cleanLine.lowercased() == "directions" ||
                cleanLine.lowercased() == "method" ||
                cleanLine.lowercased() == "steps" ||
                cleanLine.lowercased() == "instructions")
    }
    
    static func cleanDirection(_ direction: String) -> String {
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
