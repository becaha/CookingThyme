//
//  UIControls.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

struct UIControls {
    
    @ViewBuilder
    static func AddButtonVertical(withLabel label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AddViewVertical(withLabel: label)
        }
    }
    
    static func AddViewVertical(withLabel label: String) -> some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(buttonColor())
                    .shadow(color: buttonBorder(), radius: 1)

                Image(systemName: "plus")
                    .font(Font.subheadline.weight(.bold))
                    .foregroundColor(mainColor())
            }
            
            Text("\(label)")
                .font(Font.subheadline.weight(.bold))
        }
    }
    
    static func AddViewHorizontal(withLabel label: String) -> some View {
        HStack {
            AddView(withLabel: label)
        }
    }
    
    static func AddView(withLabel label: String) -> some View {
        Group {
            ZStack {
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(buttonColor())
                    .shadow(color: buttonBorder(), radius: 1)

                Image(systemName: "plus")
                    .font(Font.subheadline.weight(.bold))
                    .foregroundColor(mainColor())
            }

            Text("\(label)")
                .font(Font.subheadline.weight(.bold))
        }
    }
    
    static func AddButtonView() -> some View {
        ZStack {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(buttonColor())
                .shadow(color: buttonBorder(), radius: 1)

            Image(systemName: "plus")
                .font(Font.subheadline.weight(.bold))
        }
    }
    
    @ViewBuilder
    static func AddButton(withLabel label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AddViewHorizontal(withLabel: label)
        }
    }
    
    // TODO: cute loading https://medium.com/better-programming/create-an-awesome-loading-state-using-swiftui-9815ff6abb80
    @ViewBuilder
    static func Loading() -> some View {
        HStack {
            Spacer()
            
            ProgressView()
                .frame(alignment: .center)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    static func EditButton(action: @escaping () -> Void, isEditing: Bool) -> some View {
        Button(action: action) {
            Text(isEditing ? "Done" : "Edit")
        }
    }
    
    @ViewBuilder
    static func AddButton(action: @escaping () -> Void, isPlain: Bool = true) -> some View {
        if isPlain {
            Button(action: action) {
                Image(systemName: "plus")
                    .frame(width: 20, height: 20, alignment: .center)
            }
            .buttonStyle(PlainButtonStyle())
        }
        else {
            Button(action: action) {
                Image(systemName: "plus")
                    .frame(width: 20, height: 20, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    static func AddButtonSmall(action: @escaping () -> Void, isPlain: Bool = true) -> some View {
        if isPlain {
            Button(action: action) {
                Image(systemName: "plus")
                    .font(Font.subheadline.weight(.semibold))
                    .frame(width: 20, height: 20, alignment: .center)
            }
//            .frame(minWidth: 44, minHeight: 44)
            .buttonStyle(PlainButtonStyle())
        }
        else {
            Button(action: action) {
                Image(systemName: "plus")
                    .font(Font.subheadline.weight(.semibold))
                    .frame(width: 20, height: 20, alignment: .center)
            }
//            .frame(minWidth: 44, minHeight: 44)
        }
    }
}
