//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    
    @State var email: String = ""
    @State var username: String = """
                                    turn off the heat and add cooked chicken and stir until well mixed. you have have to add some more corn starch to get the suace to thicken up a bit.
                                    """
    @State var password: String = ""
    @State var isSigningIn: Bool = false
    
    @State var signinErrorMessage = ""
    @State var signupErrorMessage = ""
    
    var list = ["at as teh one has multililne efforts to make it into a full two lines instead of one","b", "c", "D", "e"]
    
    @State var editItemIndex: Int?
    @State var editItemLocation: CGPoint?
    
    var body: some View {
        NavigationView {
            
            ZStack {
                GeometryReader { geometry in
                
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach (0..<list.count, id: \.self) { index in
//                                    GeometryReader { geometryItem in
                                        HStack {
                                            Image(systemName: "circle")
                                                .resizable()
                                                .frame(width: 20, height: 20)

                                            Text("\(list[index])")
                                        }
                                        .formSectionItem()
                                        .onTapGesture(count: 1, perform: {
                                            editItemIndex = index
//                                                        editItemLocation = CGPoint(x: geometryItem.frame(in: .global).midX, y: geometryItem.frame(in: .global).minY)
                                        })
//                                    }
                             }
                             .onDelete { indexSet in // (4)
                                // The rest of this function will be added later
                             }

                        }
                        .formSection()
                    }
                    .navigationBarTitle("Tasks")
                    .background(formBackgroundColor())
                    .opacity(editItemIndex != nil ? 0.5 : 1)
                    .disabled(editItemIndex != nil)
                    
                    
                    if editItemIndex != nil {
                        VStack {
                            Spacer()
                            
                            HStack {
                                TextEditor(text: $username)
                            }
                            
                            Spacer()
                        }
                        .frame(maxHeight: 200)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.black)
                        )
                        .padding()

                    }
                }
            }
        }
        .gesture(editItemIndex != nil ? TapGesture(count: 1).onEnded {
            withAnimation {
                editItemLocation = nil
                editItemIndex = nil            }
        } : nil)
//        .onTapGesture(count: 1, perform: {
//            withAnimation {
//                editItemLocation = nil
//                editItemIndex = nil
//            }
//        })
    }
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
