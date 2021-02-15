//
//  ShoppingItem.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import Foundation
import GRDB
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
    
    init(name: String, amount: Double?, unitName: UnitOfMeasurement, collectionId: String, completed: Bool = false) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        self.id = UUID().uuidString
//        let id = Double.random(in: 1..<2000) * Double.random(in: 1..<2000) + Double.random(in: 1..<2000)
//        if let uuid = Int(UUID().uuidString) {
//            self.id = uuid
//        }
//        else {
//            self.id = Int(id)
//        }
        self.collectionId = collectionId
        self.completed = completed
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        amount = row[Table.amount]
        let completedInt: Int = row[Table.completed]
        completed = completedInt.toBool()
        collectionId = row[Table.collectionId]
        
        let unitString: String = row[Table.unitName]
        unitName = UnitOfMeasurement.fromString(unitString: unitString)
    }
    
    init(document: DocumentSnapshot) {
        id = ""
        name = ""
        amount = 0
        let completedInt: Int = 0
        completed = completedInt.toBool()
        collectionId = ""
        
        let unitString: String = ""
        unitName = UnitOfMeasurement.unknown("")
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
