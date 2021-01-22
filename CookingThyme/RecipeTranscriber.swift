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
        htmlTranscriber.createTranscription(fromUrlString: urlString) { recipe in
            self.setRecipe(recipe)
        }
    }
    
    func setRecipe(_ recipe: Recipe) {
        self.recipe = recipe
    }

    func createTranscription(fromImage uiImage: UIImage) {
        imageTranscriber.createTranscription(fromImage: uiImage) { transcription in
            self.setTranscription(transcription)
        }
    }
    
    func setTranscription(_ transcription: Transcription) {
        analyzeTranscription(transcription)
        self.recipeText = transcription.annotations[0].description
    }
    
    
    func analyzeTranscription(_ transcription: Transcription) {
        printTranscriptionJson(transcription)
        for annotation in transcription.annotations {
            print(annotation)
        }
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
