//
//  ContentView.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        
        Group{
            if authViewModel.userSession != nil {
                profileScreen()
            } else {
                loginScreen()
                //registerScreen()
            }
        }
    }
}

#Preview {
    ContentView()
}
