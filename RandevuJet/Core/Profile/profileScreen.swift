//
//  profileScreen.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import Foundation
import SwiftUI

struct profileScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    var body: some View {
        
        if let user = authViewModel.currentUser {
            List {
                Section() {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.gray)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4){
                            Text(user.nameSurname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            Text(user.email)
                                .font(.footnote)
                                .accentColor(.gray)
                        }
                    }
                }
                //theme
                Section() {
                    HStack {
                        Image(systemName: themeViewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.gray)
                        
                        Text("Tema")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $themeViewModel.isDarkMode)
                            .labelsHidden()
                    }
                    .padding(.top, 2)
                }
                
                // language
                Section {
                    HStack {
                        // Bayrak ikonu (emoji)
                        Text("🌐")
                            .font(.title2)
                        
                        // Dil metni
                        Text("Language")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        // Toggle içinde TR - EN metni
                        Toggle(isOn: .constant(false)) {
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                    }
                    .padding(.top, 2)
                }
                
                
                // Version
                Section() {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        
                        Text("Version")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
                
                
                // logout
                Section {
                    Button(action: {
                        Task {
                            do {
                                try await authViewModel.signOut()
                            } catch {
                                print("Çıkış yaparken hata oluştu: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.gray)
                            Text("Çıkış Yap")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        else{
            ProgressView()
                .onAppear {
                    Task {
                        do {
                            try await authViewModel.fetchUserData()
                        } catch {
                            print("Hata: \(error)")
                        }
                    }
                }
        }
        
        
    }
}

#Preview {
    profileScreen()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeViewModel())
}
