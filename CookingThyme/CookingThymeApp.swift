//
//  CookingThymeApp.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/18/20.
//

// https://stackoverflow.com/questions/57847239/xcode-source-control-push-local-changes-stuck-on-loading

import SwiftUI

@main
struct CookingThymeApp: App {
    @ObservedObject var account = AccountHandler()
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(mainColor())
        UIView.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = UIColor(mainColor())
        
        let username = "Becca"
        account = AccountHandler(username: username)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(account)
        }
    }
}

// MARK: - ASSETS

func mainColor() -> Color {
    return Color(UIColor.systemGreen)
}

func mainUIColor() -> UIColor {
    return UIColor.systemGreen
}

func formBackgroundColor() -> Color {
    if let uiColor = UIColor(named: "FormBackground") {
        return Color(uiColor)
    }
    return Color(UIColor.systemFill)
}

func formBorderColor() -> Color {
    if let uiColor = UIColor(named: "FormBorder") {
        return Color(uiColor)
    }
    return Color(UIColor.gray)
}
