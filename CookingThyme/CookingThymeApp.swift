//
//  CookingThymeApp.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/18/20.
//

// https://stackoverflow.com/questions/57847239/xcode-source-control-push-local-changes-stuck-on-loading

import SwiftUI
import Firebase

@main
struct CookingThymeApp: App {
    @ObservedObject var user = UserVM()
    @ObservedObject var timer = TimerHandler()
    @ObservedObject var sheetNavigator = SheetNavigator()
    @ObservedObject var recipeSearchHandler = RecipeSearchHandler()

    @UIApplicationDelegateAdaptor(Delegate.self) var delegate
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(mainColor())
        UIView.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = UIColor(mainColor())
        // sets current logged in user
        if let currentUsername = UserDefaults.standard.string(forKey: User.userKey) {
            self.user = UserVM(email: currentUsername)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(user)
                .environmentObject(sheetNavigator)
                .environmentObject(timer)
                .environmentObject(recipeSearchHandler)
        }
    }
}

class Delegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return true
    }
}

func unfocusEditable() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
}

// MARK: - ASSETS

func mainFont() -> String {
    return "Thonburi"
}

func mainColor() -> Color {
    return Color(UIColor.systemGreen)
}

func mainUIColor() -> UIColor {
    return UIColor.systemGreen
}

func lightFormBackgroundColor() -> Color {
    return getAssetColor(withName: "FormBackgroundLight")
}

func navBarFont() -> Color {
    return getAssetColor(withName: "NavBarFont")
}

func navBarColor() -> Color {
    return getAssetColor(withName: "NavBar")
}

func formItem() -> Color {
    return getAssetColor(withName: "FormItem")
}

func formItemFont() -> Color {
    return getAssetColor(withName: "FormItemFont")
}

func formBackgroundColor() -> Color {
    return getAssetColor(withName: "FormBackground")
}

func formBorderColor() -> Color {
    return getAssetColor(withName: "FormBorder")
}

func buttonColor() -> Color {
    return getAssetColor(withName: "Button")
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

func placeholderFontColor() -> Color {
    return getAssetColor(withName: "Placeholder")
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
