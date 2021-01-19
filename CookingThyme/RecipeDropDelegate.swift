//
//  RecipeDropDelegate.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/19/21.
//

import SwiftUI

struct RecipeDropDelegate: DropDelegate {
//    @Binding var active: Int
    let onDrop: () -> Void
    
    func validateDrop(info: DropInfo) -> Bool {
        print("a")
        return info.hasItemsConforming(to: ["public.file-url"])
    }
    
    func dropEntered(info: DropInfo) {
//        NSSound(named: "Morse")?.play()
        print("a")
    }
    
    func performDrop(info: DropInfo) -> Bool {
//        NSSound(named: "Submarine")?.play()
        print("a")
        onDrop()
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
//        self.active = getGridPosition(location: info.location)
        print("a")
        return nil
    }
    
    func dropExited(info: DropInfo) {
//        self.active = 0
        print("a")
    }
}
