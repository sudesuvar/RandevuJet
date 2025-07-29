//
//  RandevuJetApp.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import SwiftUI
import Firebase

@main
struct RandevuJetApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject private var themeViewModel = ThemeViewModel()
    @StateObject var hairdresserViewModel = HairdresserViewModel()
    @StateObject var appoinmentViewModel = AppoinmentViewModel() 
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                splashScreen()
                    .environmentObject(authViewModel)
                    .environmentObject(themeViewModel)
                    .environmentObject(hairdresserViewModel)
                    .environmentObject(appoinmentViewModel) 
                    .preferredColorScheme(themeViewModel.isDarkMode ? .dark : .light)
            }
        }
    }
}

