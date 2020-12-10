//
//  WebUnit.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

struct WebUnit {
    var name: String?
    var abbreviation: String?
    
    init(name: String?, abbreviation: String?) {
        self.name = name
        self.abbreviation = abbreviation
    }
    
    init() {}
}
