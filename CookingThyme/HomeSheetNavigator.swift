//
//  HomeSheetNavigator.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/26/21.
//

import SwiftUI

class SheetNavigator: ObservableObject {
    @Published var showSheet = false
    
    var sheetDestination: SheetDestination = .signin {
        didSet {
            showSheet = true
        }
    }
    
    enum SheetDestination {
        case settings
        case signin
    }
    
  func sheetView() -> some View {
      switch sheetDestination {
      case .settings:
          return Settings().eraseToAnyView()
      case .signin:
          return SigninView().eraseToAnyView()
      }
  }
    
    func navView() -> some View {
        NavigationView {
            sheetView()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.showSheet = false
                }) {
                    Text("Done")
                })
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
