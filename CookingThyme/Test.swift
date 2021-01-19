//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct Test: View {
    var categories = ["a", "b", "c"]
    var recipes = ["ra", "rb", "rc"]
    
    var body: some View {
        VStack {
            HStack {
                ForEach(categories, id: \.self) { category in
                    Circle()
                        .frame(width: 40, height: 40)
                        .padding()
                }
            }
            
            VStack {
                ForEach(recipes, id: \.self) { recipe in
                    NavigationLink(destination: Text("Recipe")) {
                        Text("\(recipe)")
                            .formItem(isNavLink: true)
                    }
                }
            }
        }
//        .padding()
        .foregroundColor(mainColor())
        .background(formBackgroundColor())
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
