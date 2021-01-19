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
    @ObservedObject var user = UserVM()
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(mainColor())
        UIView.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = UIColor(mainColor())
        // sets current logged in user
        if let currentUsername = UserDefaults.standard.string(forKey: User.userKey) {
            self.user = UserVM(username: currentUsername)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(user)
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

func borderColor() -> Color {
    if let uiColor = UIColor(named: "Border") {
        return Color(uiColor)
    }
    return Color.gray
}
