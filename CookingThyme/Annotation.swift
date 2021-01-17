//
//  Annotation.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/4/21.
//

import Foundation

//struct Annotation {
//    var description: String
//    var boundingPoly: [(Int, Int)]
//
//    init(description: String, boundingPoly: [(Int, Int)]) {
//        self.description = description
//        self.boundingPoly = boundingPoly
//    }
//
//    init() {
//        description = ""
//        boundingPoly = [(Int, Int)]()
//    }
//}

struct Annotation: Encodable {
    var description: String
    var boundingPoly: [Vertex]
    
    init(description: String, boundingPoly: [Vertex]) {
        self.description = description
        self.boundingPoly = boundingPoly
    }
    
    init() {
        description = ""
        boundingPoly = [Vertex]()
    }
}

struct Vertex: Encodable {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init() {
        self.x = 0
        self.y = 0
    }
}
