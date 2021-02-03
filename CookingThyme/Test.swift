//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    
    @State var email: String = "email"
    @State var username: String = """
                                    turn off the heat and add cooked chicken and stir until well mixed. you have have to add some more corn starch to get the suace to thicken up a bit.
                                    """
    @State var password: String = ""
    @State var isSigningIn: Bool = false
    
    @State var signinErrorMessage = ""
    @State var signupErrorMessage = ""
    
    var list = ["at as teh one has multililne efforts to make it into a full two lines instead of one","b", "c", "D", "e"]
    
    @State var editingIndex: Int = 1
    
    var body: some View {
        VStack {
            HStack {
        HStack {
            ZStack {
                HStack {
                    RecipeControls.ReadIngredientText(email)
                        .padding()

                    Spacer()
                }
                .opacity(editingIndex != 0 ? 1 : 0)

                if editingIndex == 0 {
                    VStack {
                        Spacer()
                        
                        EditableTextView(textBinding: $email, isFirstResponder: true)
                            .onChange(of: email) { value in
                                if value.hasSuffix("\n") {
//                                    commitIngredient()
                                    withAnimation {
                                        // unfocus
//                                        unfocusEditable()
//                                        editingIndex = nil
                                    }
                                }
                            }
     
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
            }
        .background(Color.gray)
        .simultaneousGesture(
            TapGesture(count: 1).onEnded { _ in
                editingIndex = 0
//                unfocusEditable()
//                editingIndex = index
            }
        )
            Spacer()
        }
        .formSectionItem()
    }
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
