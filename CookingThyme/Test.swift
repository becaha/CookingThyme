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
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                            
                            Image(systemName: "plus")
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .zIndex(1)
                        
                    
                ScrollView(.horizontal) {
                    HStack {
//                        VStack {
//                            ZStack {
//                                Circle()
//                                    .fill(Color.white)
//
//                                Image(systemName: "plus")
//                                    .foregroundColor(.black)
//
//                                Circle()
//                                    .stroke(Color.black, lineWidth: 1)
//                                    .shadow(radius: 5)
//                            }
//                            .frame(width: 60, height: 60)
    //
    //                            Text("Add Category")
    //                                .font(.subheadline)
    //                                .foregroundColor(.black)
    //                        }
    //                        .padding()
                            
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    
                                }) {
                                    VStack {
                                        ZStack {
//                                            CircleImage(width: 60, height: 60)
                                            
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1)
                                                .shadow(radius: 5)
                                        }
                                        .frame(width: 60, height: 60)
                                        
                                        Text("\(category)")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .background(formBackgroundColor())
                .border(Color.white, width: 2)
                
                
                List {
                    ForEach(recipes, id: \.self) { recipe in
                        Text("\(recipe)")
                    }
                }
                .padding(.top, 0)
            }
            .navigationBarHidden(true)
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
