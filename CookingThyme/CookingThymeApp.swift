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
    @ObservedObject var timer = TimerHandler()
    @ObservedObject var sheetNavigator = SheetNavigator()
    
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
                .environmentObject(sheetNavigator)
                .environmentObject(timer)
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
    return getAssetColor(withName: "FormBackground")
}

func formBorderColor() -> Color {
    return getAssetColor(withName: "FormBorder")
}

func borderColor() -> Color {
    return getAssetColor(withName: "Border")
}

func searchBarColor() -> Color {
    return getAssetColor(withName: "SearchBar")
}

func searchFontColor() -> Color {
    return getAssetColor(withName: "SearchFont")
}

func getAssetColor(withName name: String) -> Color {
    if let uiColor = UIColor(named: name) {
        return Color(uiColor)
    }
    return Color.gray
}

func logo() -> Image {
    return Image("LogoFont")
}
