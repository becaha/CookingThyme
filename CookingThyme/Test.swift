//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    
    @State var email: String = ""
    @State var username: String = "2 tablespoon oil divided plus more for frying"
    @State var password: String = ""
    @State var isSigningIn: Bool = false
    
    @State var signinErrorMessage = ""
    @State var signupErrorMessage = ""
    
    var body: some View {
        NavigationView {
        ScrollView(.vertical) {
        VStack{
        VStack(spacing: 0) {
        VStack(spacing: 0) {

                    Text("Title")
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Ingredients")
                                .textCase(.uppercase)
                            
                            Spacer()
                        }
                        .padding([.leading, .top])
                        .padding(.bottom, 5)
                        
                        VStack(spacing: 0) {
                            ForEach((1...20).reversed(), id: \.self) { index in
                                HStack {
                                    HStack {
                                        ZStack {
                                            TextEditor(text: $username)
                                            
                                            Text(username).opacity(0).padding(.all, 8)
                                        }
                                    }
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
                                    TextField("Amount ", text: $email)
                                        .keyboardType(.numbersAndPunctuation)
                                        .fixedSize()

                                    TextField("Unit ", text: $password)
                                        .autocapitalization(.none)
                                        .fixedSize()

                                    TextField("Name", text: $password,
                                        onCommit: {
                                            withAnimation {
//                                                addIngredient()
                                            }
                                        })
                                        .autocapitalization(.none)
                                    
                                    UIControls.AddButton(action: {
                                        withAnimation {
//                                            addIngredient()
                                        }
                                    })
                                }
                                .formSectionItem()
                                    
                                ErrorMessage("Must fill in an ingredient slot", isError: $isSigningIn)
                            }
                        }
                        .formSection()
                    }
                }
        }
        }
        }
        .background(formBackgroundColor())
        .navigationBarTitle("NavTitlle", displayMode: .inline)
        }
    }
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
