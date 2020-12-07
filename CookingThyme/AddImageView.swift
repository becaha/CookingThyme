//
//  AddImageView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/4/20.
//

import SwiftUI

struct AddImageView: View {

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView(.horizontal) {
                    
                    HStack {
                        Text("A")
                            .frame(width: 100)
                            .border(Color.black)

                        
                        Text("A")
                            .frame(width: 100)
                            .border(Color.black)



                        Text("A")
                            .frame(width: 100)
                            .border(Color.black)

                        Text("A")
                            .frame(width: 100)
                            .border(Color.black)

                        Text("A")
                            .frame(width: 100)
                            .border(Color.black)


                    }
                    .padding(.horizontal)
                    .frame(minWidth: geometry.size.width)


                }
                .border(Color.black)
            }
        }
        .frame(width: 300, height: 100)
    }
}

struct AddImageView_Previews: PreviewProvider {
    static var previews: some View {
        AddImageView()
    }
}
