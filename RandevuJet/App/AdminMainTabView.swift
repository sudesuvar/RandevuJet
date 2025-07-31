//
//  AdminMainTabView.swift
//  RandevuJet
//
//  Created by sude on 31.07.2025.
//

import Foundation
import SwiftUI

struct AdminMainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    var body: some View {
        TabView {
            AdminHomeScreen()
                .tabItem {
                    Label("Anasayfa", systemImage: "house")
                }
            AdminProfileScreen()
                .tabItem {
                    Label("Profil", systemImage: "person.circle")
                }
        }
    }
}


struct AdminMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        AdminMainTabView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeViewModel())
            .environmentObject(HairdresserViewModel())
    }
}

