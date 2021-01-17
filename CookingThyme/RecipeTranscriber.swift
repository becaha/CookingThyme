//
//  RecipeTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/16/21.
//

import Foundation

class RecipeTranscriber {
    static func analyzeTranscription(_ transcription: Transcription) {
        printTranscriptionJson(transcription)
        for annotation in transcription.annotations {
            print(annotation)
        }
    }
    
    static func printTranscriptionJson(_ transcription: Transcription) {
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
