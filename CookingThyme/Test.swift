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
                        .frame(width: 20, height: 20)
                        .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                            return drop(providers: providers, category: category)
                        }
                        .padding()
                }
            }
            
            VStack {
                ForEach(recipes, id: \.self) { recipe in
                    Text("\(recipe)")
                        .onDrag {
                            NSItemProvider(object: recipe as NSString)
                        }
                        .padding()
                }
            }
        }
        .padding()
        .foregroundColor(mainColor())
        .background(formBackgroundColor())
    }
    
    func moveRecipe(_ recipe: String, toCategory category: String) {
        let val = recipe
        print(val)
    }
    
    private func drop(providers: [NSItemProvider], category: String) -> Bool {
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: String.self) }) {
            let _ = provider.loadObject(ofClass: String.self) { object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        moveRecipe(value, toCategory: category)
                    }
                }
            }

            return true
        }

        return false
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
