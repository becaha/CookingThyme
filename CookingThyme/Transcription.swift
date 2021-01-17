//
//  Transcription.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/4/21.
//

import Foundation

struct Transcription: Encodable {
    var annotations: [Annotation]
//    var fullAnnotation: Annotation
    
    init(annotations: [Annotation]) {
        self.annotations = annotations
//        self.fullAnnotation = annotations[0]
    }
    
    init() {
        annotations = [Annotation]()
    }
}
