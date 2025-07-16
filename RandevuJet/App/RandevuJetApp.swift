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
    
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            splashScreen().environmentObject(authViewModel)
        }
    }
}
