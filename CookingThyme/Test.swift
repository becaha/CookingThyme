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

                ForEach((1...20).reversed(), id: \.self) { num in
                    VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 20) {
                        Group {
                            Text("\(num + 1)")

                            Text("long long long text that will go through the next line")
                        }
                    }
                    .formSectionItem()

                        
                        HStack {
                            Image(systemName: "cart.fill")

                            Button("Add to Shopping List", action: {
                                withAnimation {
    //                                callAddToShoppingList(ingredient)
                                }
                            })
                            
                            Spacer()
                        }
//                        .padding(.horizontal)
//                        .padding(.top, 5)
                        .foregroundColor(mainColor())
                        .formSectionItem(backgroundColor: formBorderColor())
                    }
                    .foregroundColor(.black)
//                    .formSectionItem()
                    
//                    HStack {
//                        Image(systemName: "cart.fill")
//
//                        Button("Add to Shopping List", action: {
//                            withAnimation {
////                                callAddToShoppingList(ingredient)
//                            }
//                        })
//                    }
//                    .padding()
//                    .background(mainColor())
                    
                }
            }
            .formSection()
            
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
