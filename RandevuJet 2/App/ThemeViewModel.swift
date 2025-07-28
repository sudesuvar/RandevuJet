//
//  ThemeViewModel.swift
//  RandevuJet
//
//  Created by sude on 17.07.2025.
//

import Foundation
import SwiftUI

class ThemeViewModel: ObservableObject {
    @Published var isDarkMode: Bool

       init() {
           let saved = UserDefaults.standard.bool(forKey: "isDarkMode")
           self.isDarkMode = saved
       }

       func toggleTheme() {
           isDarkMode.toggle()
           UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
       }
}
