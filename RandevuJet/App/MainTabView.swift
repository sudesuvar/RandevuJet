//
//  MainTabView.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Label("Anasayfa", systemImage: "house")
                }
            profileScreen()
                .tabItem {
                    Label("Profil", systemImage: "person.circle")
                }
        }
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeViewModel())
    }
}



