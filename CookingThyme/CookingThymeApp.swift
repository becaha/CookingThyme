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
        setupNotifications()
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
    
    func setupNotifications(){
        let stopAction = UNNotificationAction(identifier: SimpleTimer.stopAction,
              title: "Stop",
              options: UNNotificationActionOptions(rawValue: 0))
        let repeatAction = UNNotificationAction(identifier:  SimpleTimer.stopAction,
              title: "Repeat",
              options: UNNotificationActionOptions(rawValue: 0))
        // Define the notification type
        let timerCategory =
            UNNotificationCategory(identifier: SimpleTimer.timerAlertCategory,
              actions: [stopAction, repeatAction],
              intentIdentifiers: [],
              hiddenPreviewsBodyPlaceholder: "",
              options: .customDismissAction)
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([timerCategory])
    }
}

class Delegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return true
    }
    
    // background notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse,
           withCompletionHandler completionHandler:
             @escaping () -> Void) {
           
       // Get the meeting ID from the original notification.
//       let userInfo = response.notification.request.content.userInfo
//       let meetingID = userInfo["MEETING_ID"] as! String
//       let userID = userInfo["USER_ID"] as! String
            
       // Perform the task associated with the action.
       switch response.actionIdentifier {
       case SimpleTimer.stopAction:
//            timer.stop()
            break
            
       case SimpleTimer.repeatAction:
//            timer.repeatTimer()
            break
     
       default:
          break
       }
        
       // Always call the completion handler when done.
       completionHandler()
    }
    
    // foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
             willPresent notification: UNNotification,
             withCompletionHandler completionHandler:
                @escaping (UNNotificationPresentationOptions) -> Void) {
        print("")

       // Don't alert the user for other types.
       completionHandler(UNNotificationPresentationOptions(rawValue: 0))
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

func background() -> Color {
    return getAssetColor(withName: "Background")
}

func buttonBorder() -> Color {
    return getAssetColor(withName: "ButtonBorder")
}

func item() -> Color {
    return getAssetColor(withName: "Item")
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

func selectedShadowColor() -> Color {
    return getAssetColor(withName: "SelectedShadow")
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
