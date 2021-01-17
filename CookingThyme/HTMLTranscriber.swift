//
//  HTMLTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/16/21.
//

import SwiftUI

class HTMLTranscriber: ObservableObject {
    
    func getHTML(fromUrlString urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Error: \(urlString) doesn't seem to be a valid URL")
            return
        }

        do {
            let htmlString = try String(contentsOf: url, encoding: .ascii)
            print("HTML : \(htmlString)")
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func createTranscription(fromHTMLString htmlString: String) -> Transcription {
        let annotations = [Annotation]()
        let transcription = Transcription(annotations: annotations)
        return transcription
    }
}

