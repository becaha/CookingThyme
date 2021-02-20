//
//  ShoppingItem.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import Foundation
import Firebase

//TODO history of shopping items
struct ShoppingItem: Identifiable {
    struct Table {
        static let databaseTableName = "ShoppingItem"
        
        static let id = "Id"
        static let name = "Name"
        static let amount = "Amount"
        static let unitName = "UnitName"
        static let completed = "Completed"
        static let collectionId = "CollectionId"
    }
    
    static let defaultId = ""
    
    var id: String
    var name: String
    var amount: Double?
    var unitName: UnitOfMeasurement
    var completed: Bool
    var collectionId: String
    
    var defaultId: String
    
    init(name: String, amount: Double?, unitName: UnitOfMeasurement, collectionId: String, completed: Bool = false) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        // temp, TODO no dupllicates addable
        self.id = name
        self.collectionId = collectionId
        self.completed = completed
        self.defaultId = name
    }
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        name = document.get(Table.name) as? String ?? ""
        amount = document.get(Table.amount) as? Double ?? 0
        let completedInt: Int = document.get(Table.completed) as? Int ?? 0
        completed = completedInt.toBool()
        collectionId = document.get(Table.collectionId) as? String ?? RecipeCollection.defaultId
        
        let unitString: String = document.get(Table.unitName) as? String ?? ""
        unitName = UnitOfMeasurement.fromString(unitString: unitString)
        self.defaultId = name
    }
    
    // converts shopping item to one line string (1 cup apple juice)
    func toString() -> String {
        var string = ""
        if let amountDouble = self.amount, amountDouble != 0 {
            string += Fraction.toString(fromDouble: amountDouble) + " "
        }
        if self.unitName.getName() != "" {
            string += self.unitName.getName() + " "
        }
        string += self.name
        return string
    }
}

extension Bool {
    func toInt() -> Int {
        if self {
            return 1
        }
        return 0
    }
}

extension Int {
    func toBool() -> Bool {
        if self == 0 {
            return false
        }
        return true
    }
}
