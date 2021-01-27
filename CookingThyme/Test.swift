//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var isSigningIn: Bool = true
    
    @State var signinErrorMessage = ""
    @State var signupErrorMessage = ""
    
    var body: some View {
        ScrollView(.vertical) {
            Text("Title")
            
//            VStack(spacing: 0) {
//                HStack {
//                    Text("INGREDIENTS")
//
//                    Spacer()
//                }
//                .padding([.leading, .top])
//                .padding(.bottom, 5)
//
//                VStack(spacing: 0) {
//                    ForEach((1...20).reversed(), id: \.self) { num in
//                        Text("\(num)")
//                            .formSectionItem()
//                    }
//                }
//                .formSection()
//            }
            
            VStack(spacing: 0) {
                HStack {
                    Text("directions")
                        .textCase(.uppercase)
                    
                    Spacer()
                }
                .padding([.leading, .top])
                .padding(.bottom, 5)
                
                VStack(spacing: 0) {
                    ForEach((1...2).reversed(), id: \.self) { index in
                        HStack {
                            TextField("1 1/2", text: $username)
                                .keyboardType(.numbersAndPunctuation)
                                .fixedSize()
                            
                            TextField("cup", text: $email)
                                .fixedSize()
                            
                            TextField("flour", text: $password)
                        }
                        .deletable(isDeleting: true, onDelete: {
                            withAnimation {
    //                            recipe.removeTempIngredient(at: index)
                            }
                        })
                        .formSectionItem()
                    }
                    .onDelete { indexSet in
                        indexSet.map{ $0 }.forEach { index in
//                            recipe.removeTempIngredient(at: index)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            TextField("Amount ", text: $username)
                                .keyboardType(.numbersAndPunctuation)
                                .fixedSize()
                                
                            TextField("Unit ", text: $email)
                                .autocapitalization(.none)
                                .fixedSize()

                            TextField("Name", text: $password,
                                onCommit: {
                                    withAnimation {
//                                        addIngredient()
                                    }
                                })
                                .autocapitalization(.none)
                            
                            UIControls.AddButton(action: {
                                withAnimation {
//                                    addIngredient()
                                }
                            })
                        }
                        .formSectionItem()
                    }
                }
                .formSection()
            }
            
        }
        .padding()
        .accentColor(mainColor())
        .background(formBackgroundColor())
        .ignoresSafeArea()
    }
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
