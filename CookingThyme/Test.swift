//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct Test: View {
    let categories = ["All", "Sides", "Main Dishes", "All", "Sides", "Main", "All", "Sides", "Main"]
    let recipes = ["A", "B", "C"]
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(mainColor())
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            }
            .frame(width: 60, height: 60)
            .shadow(color: Color.gray, radius: 1)

            ZStack {
                Circle()
                    .fill(mainColor())
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            }
            .frame(width: 60, height: 60)
            .shadow(color: Color.gray, radius: 5)
            .padding(.horizontal)

            
            ZStack {
                Circle()
                    .fill(mainColor())
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            }
            .frame(width: 60, height: 60)
            .shadow(color: Color.gray, radius: 1)
            
            Menu {
                Button(action: {
                    
                }) {
                    Label("Add", systemImage: "plus.circle")
                }
                Button(action: {
                    
                }) {
                    Label("Delete", systemImage: "minus.circle")
                }
                Button(action: {
                    
                }) {
                    Label("Edit", systemImage: "pencil.circle")
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .opacity(0.8)
                    
                    Image(systemName: "pencil")
                        .foregroundColor(.black)
                }
            }
            
        }
        .padding()
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
