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
                ForEach((1...20).reversed(), id: \.self) { num in
                    NavigationLink(destination: Text("Recipe")) {
                        Text("\(num)")
                            .formItem(isNavLink: true)
                    }
                }
                
                Spacer()
            }
            .formed()

            VStack {
                
                HStack {
                    Button(action: {
//                        createRecipe()
                    }) {
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(mainColor())

                                Image(systemName: "plus")
                                    .font(Font.subheadline.weight(.bold))
//                                    .imageScale(.small)
                                    .foregroundColor(.white)
                            }
                            
                            Text("New Recipe")
                                .bold()
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 5)
        }
        .foregroundColor(mainColor())
        .background(formBackgroundColor())
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
